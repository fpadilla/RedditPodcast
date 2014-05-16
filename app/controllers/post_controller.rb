require "voice_bunny"

class PostController < ApplicationController
  def list
    @posts = reddit.front_page :category => :top, :time => :all
  end
  
  def show
    puts params
    @post = Post.find_by(redditId: params[:id])
    @link = reddit.link("t3_#{params[:id]}")
  end
  
  # request cast to voice bunny 
  def cast
    
    # retrieve link information
    @link = reddit.link("t3_#{params[:id]}")

    # request Speedy
    project = {
        script: @link.title,
        title: 'Reddit Podcast',
        #test: 1,
        ping: "#{request.protocol}#{request.host_with_port}/castDone/#{@link.id}",
        auditionScript: @link.title,
        maxEntries: 3,
        language: 'eng-us',
        genderAndAge: 'middleAgeMale',
        lifetime: 86400,
        remarks: 'I want a really friendly voice',
        syncedRecording: 1,
        price: 35
    }
    project = VoiceBunny.instance.addSpeedy(project)
    
    # save the project id in the post model
    if project
        @post = Post.new(redditId: @link.id, 
                vbProjectId: project["id"], 
                url: @link.url )
        @post.save
    end
    
    redirect_to :action => :show
  end
  
  # ping action from Voice Bunny Api, save the url of the read
  def castDone
        @post = Post.find_by(redditId: params[:id])
        project = VoiceBunny.instance.getProject(@post.vbProjectId)
        @post.vbReadUrl = project["reads"][0]["urls"]["part001"]["default"]
        @post.save
        render :status => 200
  end
  
  # Reedit client method
  def reddit
    if !@redditClient 
        @redditClient = RedditKit::Client.new 'fpadillao', 'tr1n1tar1a'
    end
    return @redditClient
  end
  
  def root 
  end
  
end
