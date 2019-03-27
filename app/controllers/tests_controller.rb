class TestsController < Simpler::Controller

  def index
    @time = Time.now
    # render plain: "plain text response\n"
    # status 201
    # headers['Simpler-Special'] = 'something/cool'
  end

  def create; end

  def show
    @params = params
  end
end
