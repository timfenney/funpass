require_relative '../conf'

class KeyMaker
  def self.ensure_key(key)
    return rand(SECRET_KEY_MODULUS) unless key
    validate key
  end

  private

  def self.validate key
    if not key.to_f == key.to_i.to_f
      raise ArgumentError, "provided key is not integral"
    end

    key = key.to_i
    if not key > 0
      raise ArgumentError, "provided key is not positive"
    end

    key
  end
end
