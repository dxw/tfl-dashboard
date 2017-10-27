require 'faraday_middleware'

class Tfl
  BASE_URI = 'https://api.tfl.gov.uk'.freeze

  attr_reader :connection

  def initialize
    @connection = Faraday.new BASE_URI do |conn|
      conn.response :xml,  content_type: /\bxml$/
      conn.response :json, content_type: /\bjson$/

      conn.adapter Faraday.default_adapter
    end
  end

  def fetch
    response = connection.get '/line/mode/tube,overground/status'

    response.body.map do |line|
      id = line.fetch('id')
      name = line.fetch('name')

      statuses = line.fetch('lineStatuses', []).flat_map do |status|
        {
          severity: status.fetch('statusSeverityDescription', ''),
          reason: status.fetch('reason', '')
        }
      end

      {
        id: id,
        name: name,
        statuses: statuses
      }
    end
  end
end
