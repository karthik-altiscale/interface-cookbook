require 'serverspec'

name = os[:family] == 'suse' ? 'iproute2' : 'iproute'

describe package(name) do
  it { should be_installed }
end

if command('/sbin/ip netns').exit_status == 0
  describe command('/sbin/ip netns') do
    its('stdout') { should_not match /dead/ }
    its('stdout') { should match /vpn/ }
    its('stdout') { should match /space/ }
  end

  describe command('/sbin/ip netns exec vpn ip link show nsvpn0') do
    its('stdout') { should match /state DOWN/ }
  end

  describe command('/sbin/ip netns exec space ip link show nsmtu0') do
    its('stdout') { should match /mtu 1400/ }
  end

  describe command('/sbin/ip netns exec space ip link show nsmac0') do
    its('stdout') { should match /aa:bb:cc:00:11:22/ }
  end

  describe command('/sbin/ip netns exec vpn ip link show nsalias0') do
    its('stdout') { should match /alias i am alias of nsalias0/ }
  end

  describe command('/sbin/ip netns exec vpn ip link show nsalias0') do
    its('stdout') { should match /qlen 12345/ }
  end

  describe interface('nsvpn0') do
    it { should_not exist }
  end

  describe interface('nsmac0') do
    it { should_not exist }
  end

  describe interface('nsalias0') do
    it { should_not exist }
  end

else
  describe interface('dumb0') do
    it { should_not be_up }
  end

  describe file('/sys/class/net/dumb1/mtu') do
    its('content') { should eq "1400\n" }
  end

  describe file('/sys/class/net/mac0/address') do
    its('content') { should eq "aa:bb:cc:00:11:22\n" }
  end

  describe command('/sbin/ip link show alias0') do
    its('stdout') { should match /alias i am alias of alias0/ }
  end

  describe command('/sbin/ip link show alias0') do
    its('stdout') { should match /qlen 12345/ }
  end
end
