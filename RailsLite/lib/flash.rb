require 'json'

class Flash

  attr_reader :flash, :now

  def initialize(req)
    @flash = {}
    if req.cookies['_rails_lite_app_flash']
      @flash = JSON.parse(req.cookies['_rails_lite_app_flash'])
    end
    @now = {}
  end

  def [](key)
    if now[key.to_s]
      now[key.to_s]
    else
      flash[key.to_s]
    end
  end

  def []=(key, val)
    @flash[key.to_s] = val
  end

  def now
    @now
  end



  def store_flash(res)
    res.set_cookie('_rails_lite_app_flash', path: '/', value: flash.to_json)
    @flash = {}
  end
end
