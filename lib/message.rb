require 'sequel'

class Message
  attr_reader :text, :score

  def message=(message)
    @message = message
    DB[:messages].insert(mid: @message, eid: @id, type: @type)
  end

  def feedback(user)
    if result = DB[:feedback].where(mid: @message, uid: user).count != 0 ? false : true
      @score += 1
      DB[@table].where(id: @id).update(score: @score)
      DB[:feedback].insert(mid: @message, uid: user)
    end
    return result
  end
end
