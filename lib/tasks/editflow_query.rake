namespace :birs do
  task default: 'birs:editflow_id'

  desc "Add response editflow ids to database"
  task editflow_id: :environment do
    query = <<END_STRING
            query {
              articles {
               id
                title
              }
            }
END_STRING

    response = RestClient.post ENV['EDITFLOW_API_URL'],
                               { query: query },
                               { x_editflow_api_token: ENV['EDITFLOW_API_TOKEN'] }

    response_body = JSON.parse(response.body)
    articles = response_body["data"]["articles"]
    articles.each do |article|
      title = article["title"]
      id = article["id"]
      code = title.split(":").first
      proposal = Proposal.find_by(code: code)
      proposal&.update(editflow_id: id)
    end
  end
end
