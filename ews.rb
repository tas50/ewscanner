#!/usr/bin/env ruby
require 'ipaddress'
require 'typhoeus'

def decode_body(resp)
  return nil if resp.nil?
  case resp.body
  when /ATEN International Co Ltd/
    'SuperMicro IPMI server'
  when /Welcome to nginx/
    'NGINX default webpage'
  when /Apache2 Ubuntu Default Page/
    'Apache2 default webpage on Ubuntu'
  when /It works!/
    'Apache2 default webpage'
  when /<title>IIS7<\/title>/
    'Microsoft IIS 7 Default Website'
  when />Click <b>Internet Information Services/
    'Microsoft IIS 6 Without Default Website'
  when /Please be patient as you are being re-directed to|SonicWALL/
    'Sonicwall Web UI'
  when /exacqVision|The advanced interface is like the/
    'exacqVision server'
  when /Polycom/
    'Polycom phone system'
  when /<frame name="banFrm" src='Banner.htm'/
    'NEC Univerge Phone System'
  when /Plesk/
    'Parallels Plesk Web Panel'
  when /XenServer/
    'Citrix Systems XenServer'
  when /OpenHIM Administration Console/
    'OpenHIM Administration Console'
  when /ARRIS Enterprises/
    'ARRIS Cable Modem'
  when /OpenHIE Demo/
    'OpenHIE Demo'
  when /brocade_logo_no_text.gif/
    'Brocade Web UI'
  when /NETGEAR Router/
    'Netgear Router'
  when /ProCurve Switch/
    'HP ProCurve Switch Web UI'
  when /Linksys Smart Wi-Fi Router/
    'Linksys Smart Wifi Router'
  when /http:\/\/www.contribs.org\/development\//
    'Kazooli SME Server Web UI'
  when /Speco WebViewer/
    'Speco DVR'
  when /FatPipe MPVPN Remote Configuration/
    'FatPipe MPVPN'
  when /Samsung DVR/
    'Samsung DVR'
  when /OpenVZ/
    'OpenVZ Web UI'
  when /RouterOS/
    'MicroTik Router'
  when /American Dynamics: Video Management Solutions/
    'American Dynamics DVR'
  when /Please Log In to continue./
    'Unknown DSL modem'
  when /iis-85.png/
    'IIS 8.5 Default Website'
  when /Metaswitch Networks/
    'Metaswitch Networks device'
  when /Surveillance_Brower_Plugin.xpi/
    'FOSCAM IP Camera'
  when /Outlook Web App/
    'Microsoft Outlook Web App'
  when /Remote\/WebResource.axd/
    'Windows Server 2012 R2 Remote Web Access'
  when /For Security reasons only authorized users are allowed to access to the web server/
    'Digital Watchdog VMAX Multichannel DVR'
  when /Play-Fi Device/
    'DTS Play-Fi Wireless Audio Device'
  when /rXg/
    'Rg Nets rXg network appliance'
  when /laSetDefaultLan/
    'Truvision DVR System'
  when /airVision/
    'Ubiquiti airVision DVR'
  when /DVR Netview/
    'Lorex DVR'
  when /Hikvision/
    'Hikvision DVR System'
  when /EnGenius/
    'Unknown EnGenius network device'
  when /flir_webplugin.exe/
    'FLIR Systems DVR System'
  when /cookie_name = "mingzi"/
    'Unknown DSL modem'
  when /Sicon-8/
    'CircuitWerkes Sicon-8 Remote Controller'
  when /SCam_2nd.SIS/
    'Unknown DVR system (possibly generic)'
  when /ccwebmail_normal/
    'Codecrafters Ability Mail Webmail'
  when /Barracuda Phone System/
    'Barracuda Phone System'
  when /pfsense_ng/
    'pfSense Firewall'
  when /AV732E/
    'AVTech DVR'
  when /IBM iNotes/
    'IBM iNotes'
  when /NmConsole\/Workspace/
    "What's Up Gold"
  when /\/gw\/webaccess/
    'Novell Groupwise'
  when /Dedicated Micros/
    'Dedicated Micros DVR'
  when /XAMPP/
    'XAMPP'
  when /WebClient_CNB_Logo/
    'CNB Tech DVR'
  when /gZoom_Capability/
    'ACTi DVR'
  when /Philips Teletrol/
    'Philips Teletrol Energy Management System'
  when /WV-\S* Network Camera/
    'Panasonic Network Camera'
  when /Vertical Summit/
    'Vertical Summit PBX'
  when /ActiveCampus/
    'Ellucian ActiveCampus'
  when /Cisco Small Business Router/
    'Cisco Small Business Router'
  when /Mitel Networks® \S* Integrated Communications Platform/
    'Mitel PBX'
  when /content="Belkin /
    'Belkin Router'
  when /Webcam Login/
    'Unknown Webcam (possibly generic)'
  when /NPClient\.html/
    'Amcrest Webcam'
  when /PcamEn\.htm/
    'Pcam Webcam'
  else
    'Unknown webserver'
  end
end

def fetch_url(ip)
  resp = Typhoeus.get(ip, ssl_verifyhost: 0, followlocation: true, accept_encoding: "gzip", timeout: 2)
  if resp.success?
    resp
  else
    nil
  end
end

def scan_ip
  while ip = @ips.pop
    STDOUT.flush
    result = decode_body(fetch_url(ip))
    puts "\e[32m#{ip}: Found #{result}!\e[0m" unless result.nil?
  end
end

puts 'You must provide a start and ending address to scan' unless ARGV[0] && ARGV[1]

@ips = IPAddress(ARGV[0]).to(ARGV[1])

# start the 50 threads
threads = []
(0..50).each do |t|
  threads << Thread.new { scan_ip }
end

#join the threads so they'll complete
threads.each do |t|
  t.join
end
