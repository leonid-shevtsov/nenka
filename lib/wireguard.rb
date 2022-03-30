module Wireguard
  def self.generate_keypair
    privatekey = `wg genkey`.strip
    pubkey = `echo '#{privatekey}' | wg pubkey`.strip
    [privatekey, pubkey]
  end
end
