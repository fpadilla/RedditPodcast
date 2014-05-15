require 'faraday'
require 'faraday_middleware'
require 'singleton'

class VoiceBunny 

include Singleton

def initialize
    @conn = nil
    @api_id = "28044"
    @api_key = "9c703071f46e690eec79c1bcb4fa280a"

    @conn = Faraday.new(:url =>("https://"+ @api_id+":"+@api_key +"@api.voicebunny.com"),:ssl => {:verify => false}) do |builder|
            builder.use Faraday::Request::Multipart
            builder.use Faraday::Request::UrlEncoded
            builder.use Faraday::Response::ParseJson
            builder.use Faraday::Adapter::NetHttp		  
    end
end 

def addSpeedy( project )
    resp = @conn.post '/projects/addSpeedy.json', project
    resp.body["project"]
end 

def getProject(id)
    resp = @conn.get '/projects/'+id+'.json'
    resp.body["projects"][0]
end

end