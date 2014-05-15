require 'faraday'
require 'faraday_middleware'

class PostController < ApplicationController
  def list
    client = RedditKit::Client.new 'fpadillao', 'tr1n1tar1a'
    @posts = client.front_page :category => :top, :time => :all
  end

  def show
  end
  
  def cast
    puts params
    @post = Post.find_by(redditId: params[:id])
    if !@post
        # retrieve link information
        client = RedditKit::Client.new 'fpadillao', 'tr1n1tar1a'
        link = client.link("t3_#{params[:id]}")

        # request Speedy
        @conn = nil
        @api_id = "28044"
        @api_key = "9c703071f46e690eec79c1bcb4fa280a"
        resp = nil

        @conn = Faraday.new(:url =>("https://"+ @api_id+":"+@api_key +"@api.voicebunny.com"),:ssl => {:verify => false}) do |builder|
            builder.use Faraday::Request::Multipart
            builder.use Faraday::Request::UrlEncoded
            builder.use Faraday::Response::ParseJson
            builder.use Faraday::Adapter::NetHttp		  
        end

        project = {
            script: link.title,
            title: 'Reddit Podcast',
            test: 1,
            auditionScript: link.title,
            maxEntries: 3,
            language: 'eng-us',
            genderAndAge: 'middleAgeMale',
            lifetime: 86400,
            remarks: 'I want a really friendly voice',
            syncedRecording: 1,
            ping: "#{request.protocol}#{request.host_with_port}/castDone/#{link.id}",
            price: 50
        }
        puts project
        resp = @conn.post '/projects/addSpeedy.json', project
        
        puts resp.body["project"]
        
        if resp.body["project"]
            @post = Post.new(redditId: link.id, 
                    vbProjectId: resp.body["project"]["id"], 
                    url: link.url )
            @post.save
        else
            # TODO: error log for VB API
            @error = resp.body
        end
        
    end

  end
  
  def castDone
       @post = Post.find_by(redditId: params[:id])
       
        # request read url
        @conn = nil
        @api_id = "28044"
        @api_key = "9c703071f46e690eec79c1bcb4fa280a"
        resp = nil

        @conn = Faraday.new(:url =>("https://"+ @api_id+":"+@api_key +"@api.voicebunny.com"),:ssl => {:verify => false}) do |builder|
            builder.use Faraday::Request::Multipart
            builder.use Faraday::Request::UrlEncoded
            builder.use Faraday::Response::ParseJson
            builder.use Faraday::Adapter::NetHttp		  
        end

        resp = @conn.get '/projects/'+@post.vbProjectId+'.json'
        puts resp.body
        @post.vbReadUrl = resp.body["projects"][0]["reads"][0]["urls"]["part001"]["default"]
        puts "URL READ #{@post.vbReadUrl}"
        @post.save
        
        render :status => 200
    
  end
  
end
