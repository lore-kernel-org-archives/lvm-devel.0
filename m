From: haaber <haaber@web.de>
Date: Wed, 3 May 2023 18:48:39 +0200
Subject: Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <5b8439e8-f7a0-c9c3-cdc8-257ee68db41c@redhat.com>
References: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
 <b987f331-b2c8-ed18-14eb-e039830ed436@gmail.com>
 <7de7fbb2-7c52-4564-e63e-e4c1523962f7@web.de>
 <5b8439e8-f7a0-c9c3-cdc8-257ee68db41c@redhat.com>
Message-ID: <0c82e706-8051-d131-91fb-f8f5556d88e7@web.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dear? Zdenek,

I had a forced break, but the subject is still active..

>
> To get to your thin-pool metadata, you have to activate LV with them.
> (lvchange -ay? vgname/thinpoolmetadata).
>
my pool is called? qubes_dom0/pool00 (now you know my previous operating
system :) So I tried

lvchange -ay? qubes_dom0/thinpoolmetadata

but that fails: ? Failed to find logical volume
"qubes_dom0/thinpoolmetadata"

Then I tried

lvchange -ay qubes_dom0/pool00_tmeta

and that worked (gave a warning). But I do not know how to run
thin_repair now :((

> Can you please provide?? 'lvs -a'? of your volume group ?

I attached that file.? It's a little mess, I fear.? Thank you for your help,


best, Bernhard

-------------- next part --------------
  LV                                                 VG         Attr       LSize    Pool   Origin                                             Data%  Meta%  Move Log Cpy%Sync Convert
  [lvol0_pmspare]                                    qubes_dom0 ewi-------  108.00m                                                                                                  
  pool00                                             qubes_dom0 twi---tz-- <214.78g                                                                                                  
  [pool00_tdata]                                     qubes_dom0 Twi------- <214.78g                                                                                                  
  [pool00_tmeta]                                     qubes_dom0 ewi-------  108.00m                                                                                                  
  root                                               qubes_dom0 Vwi---tz-- <214.78g pool00                                                                                           
  swap                                               qubes_dom0 -wi-a-----   <7.50g                                                                                                  
  vm-Android-private                                 qubes_dom0 Vwi---tz--    5.00g pool00 vm-Android-private-1633545383-back                                                        
  vm-Android-private-1633545383-back                 qubes_dom0 Vwi---tz--    5.00g pool00                                                                                           
  vm-Arbeit-private                                  qubes_dom0 Vwi---tz--   30.00g pool00 vm-Arbeit-private-1678980932-back                                                         
  vm-Arbeit-private-1678980932-back                  qubes_dom0 Vwi---tz--   30.00g pool00                                                                                           
  vm-Arbeit-private-snap                             qubes_dom0 Vwi---tz--   30.00g pool00 vm-Arbeit-private                                                                         
  vm-Arbeit-root-snap                                qubes_dom0 Vwi---tz--   20.00g pool00 vm-debian-11-root-1679130937-back                                                         
  vm-Arbeit-volatile                                 qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-Fernwartung-private                             qubes_dom0 Vwi---tz--    2.00g pool00 vm-Fernwartung-private-1604748655-back                                                    
  vm-Fernwartung-private-1604748655-back             qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-GPG-keys-private                                qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-GPG-keys-private-snap                           qubes_dom0 Vwi---tz--    2.00g pool00 vm-GPG-keys-private                                                                       
  vm-GPG-keys-root-snap                              qubes_dom0 Vwi---tz--   15.00g pool00                                                                                           
  vm-GPG-keys-volatile                               qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-PLM-private                                     qubes_dom0 Vwi---tz--    2.00g pool00 vm-PLM-private-1561430058-back                                                            
  vm-PLM-private-1561430058-back                     qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-Privat-private                                  qubes_dom0 Vwi---tz--  156.25g pool00 vm-Privat-private-1658835892-back                                                         
  vm-Privat-private-1658835892-back                  qubes_dom0 Vwi---tz--  156.25g pool00                                                                                           
  vm-Privat-private-snap                             qubes_dom0 Vwi---tz--  156.25g pool00 vm-Privat-private                                                                         
  vm-Privat-root-snap                                qubes_dom0 Vwi---tz--   20.00g pool00                                                                                           
  vm-Privat-volatile                                 qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-Tresorraum-private                              qubes_dom0 Vwi---tz--    2.00g pool00 vm-Tresorraum-private-1678980925-back                                                     
  vm-Tresorraum-private-1678980925-back              qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-Tresorraum-private-snap                         qubes_dom0 Vwi---tz--    2.00g pool00 vm-Tresorraum-private                                                                     
  vm-Tresorraum-root-snap                            qubes_dom0 Vwi---tz--   20.00g pool00 vm-debian-11-root                                                                         
  vm-Tresorraum-volatile                             qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-Verwaltung-private                              qubes_dom0 Vwi---tz--    5.99g pool00 vm-Verwaltung-private-1677926231-back                                                     
  vm-Verwaltung-private-1677926231-back              qubes_dom0 Vwi---tz--    5.99g pool00                                                                                           
  vm-Verwaltung-private-snap                         qubes_dom0 Vwi---tz--    5.99g pool00 vm-Verwaltung-private                                                                     
  vm-Verwaltung-root-snap                            qubes_dom0 Vwi---tz--   20.00g pool00 vm-debian-11-root                                                                         
  vm-Verwaltung-volatile                             qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-anon-whonix-private                             qubes_dom0 Vwi---tz--    3.00g pool00 vm-anon-whonix-private-1675500726-back                                                    
  vm-anon-whonix-private-1675500726-back             qubes_dom0 Vwi---tz--    3.00g pool00                                                                                           
  vm-buster-print-private                            qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-buster-print-root                               qubes_dom0 Vwi---tz--   10.00g pool00 vm-buster-print-root-1647866494-back                                                      
  vm-buster-print-root-1647866494-back               qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-debian-11-minimal-firewall-private              qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-debian-11-minimal-firewall-root                 qubes_dom0 Vwi---tz--   10.00g pool00 vm-debian-11-minimal-firewall-root-1677968205-back                                        
  vm-debian-11-minimal-firewall-root-1677968205-back qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-debian-11-minimal-net-private                   qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-debian-11-minimal-net-root                      qubes_dom0 Vwi---tz--   10.00g pool00 vm-debian-11-minimal-net-root-1677968245-back                                             
  vm-debian-11-minimal-net-root-1677968245-back      qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-debian-11-minimal-private                       qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-debian-11-minimal-root                          qubes_dom0 Vwi---tz--   10.00g pool00 vm-debian-11-minimal-root-1640161303-back                                                 
  vm-debian-11-minimal-root-1640161303-back          qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-debian-11-minimal-usb-private                   qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-debian-11-minimal-usb-root                      qubes_dom0 Vwi---tz--   10.00g pool00 vm-debian-11-minimal-usb-root-1640161428-back                                             
  vm-debian-11-minimal-usb-root-1640161428-back      qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-debian-11-private                               qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-debian-11-root                                  qubes_dom0 Vwi---tz--   20.00g pool00 vm-debian-11-root-1679130937-back                                                         
  vm-debian-11-root-1679130937-back                  qubes_dom0 Vwi---tz--   20.00g pool00                                                                                           
  vm-debian-dvm-private                              qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-default-mgmt-dvm-private                        qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-disp383-private-snap                            qubes_dom0 Vwi---tz--    2.00g pool00 vm-debian-dvm-private                                                                     
  vm-disp383-root-snap                               qubes_dom0 Vwi---tz--   20.00g pool00 vm-debian-11-root-1679130937-back                                                         
  vm-disp383-volatile                                qubes_dom0 Vwi---tz--   12.00g pool00                                                                                           
  vm-dummy-private                                   qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-dummy-root                                      qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-flashing-private                                qubes_dom0 Vwi---tz--    2.00g pool00 vm-flashing-private-1647856203-back                                                       
  vm-flashing-private-1647856203-back                qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-mail-privat-private                             qubes_dom0 Vwi---tz--    4.00g pool00 vm-mail-privat-private-1678980932-back                                                    
  vm-mail-privat-private-1678980932-back             qubes_dom0 Vwi---tz--    4.00g pool00                                                                                           
  vm-mail-privat-private-snap                        qubes_dom0 Vwi---tz--    4.00g pool00 vm-mail-privat-private                                                                    
  vm-mail-privat-root-snap                           qubes_dom0 Vwi---tz--   20.00g pool00 vm-debian-11-root-1679130937-back                                                         
  vm-mail-privat-volatile                            qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-mirage-builder-private                          qubes_dom0 Vwi---tz--   20.00g pool00 vm-mirage-builder-private-1652136334-back                                                 
  vm-mirage-builder-private-1652136334-back          qubes_dom0 Vwi---tz--   20.00g pool00                                                                                           
  vm-mirage-firewall-private                         qubes_dom0 Vwi---tz--    2.00g pool00 vm-mirage-firewall-private-1678980930-back                                                
  vm-mirage-firewall-private-1678980930-back         qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-mirage-firewall-private-snap                    qubes_dom0 Vwi---tz--    2.00g pool00 vm-mirage-firewall-private                                                                
  vm-mirage-firewall-root                            qubes_dom0 Vwi---tz--   10.00g pool00 vm-mirage-firewall-root-1678980930-back                                                   
  vm-mirage-firewall-root-1678980930-back            qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-mirage-firewall-root-snap                       qubes_dom0 Vwi---tz--   10.00g pool00 vm-mirage-firewall-root                                                                   
  vm-mirage-firewall-volatile                        qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-printing-private                                qubes_dom0 Vwi---tz--    2.00g pool00 vm-printing-private-1647858008-back                                                       
  vm-printing-private-1647858008-back                qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-sshkeys-private                                 qubes_dom0 Vwi---tz--    2.00g pool00 vm-sshkeys-private-1623251897-back                                                        
  vm-sshkeys-private-1623251897-back                 qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-sshkeys-private-snap                            qubes_dom0 Vwi---tz--    2.00g pool00 vm-sshkeys-private                                                                        
  vm-sshkeys-root-snap                               qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-sshkeys-volatile                                qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-sys-firewall-private                            qubes_dom0 Vwi---tz--    2.00g pool00 vm-sys-firewall-private-1678980932-back                                                   
  vm-sys-firewall-private-1678980932-back            qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-sys-firewall-private-snap                       qubes_dom0 Vwi---tz--    2.00g pool00 vm-sys-firewall-private                                                                   
  vm-sys-firewall-root-snap                          qubes_dom0 Vwi---tz--   10.00g pool00 vm-debian-11-minimal-firewall-root                                                        
  vm-sys-firewall-volatile                           qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-sys-net-private                                 qubes_dom0 Vwi---tz--    2.00g pool00 vm-sys-net-private-1678980929-back                                                        
  vm-sys-net-private-1678980929-back                 qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-sys-net-private-snap                            qubes_dom0 Vwi---tz--    2.00g pool00 vm-sys-net-private                                                                        
  vm-sys-net-root-snap                               qubes_dom0 Vwi---tz--   10.00g pool00 vm-debian-11-minimal-net-root                                                             
  vm-sys-net-volatile                                qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-sys-usb-private                                 qubes_dom0 Vwi---tz--    5.00g pool00 vm-sys-usb-private-1679256316-back                                                        
  vm-sys-usb-private-1679256316-back                 qubes_dom0 Vwi---tz--    5.00g pool00                                                                                           
  vm-sys-whonix-private                              qubes_dom0 Vwi---tz--    2.00g pool00 vm-sys-whonix-private-1678980932-back                                                     
  vm-sys-whonix-private-1678980932-back              qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-sys-whonix-private-snap                         qubes_dom0 Vwi---tz--    2.00g pool00 vm-sys-whonix-private                                                                     
  vm-sys-whonix-root-snap                            qubes_dom0 Vwi---tz--   10.00g pool00 vm-whonix-gw-16-root-1679305216-back                                                      
  vm-sys-whonix-volatile                             qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-tribler-private                                 qubes_dom0 Vwi---tz--   20.00g pool00 vm-tribler-private-1671645867-back                                                        
  vm-tribler-private-1671645867-back                 qubes_dom0 Vwi---tz--   20.00g pool00                                                                                           
  vm-untrusted-private                               qubes_dom0 Vwi---tz--   42.00g pool00 vm-untrusted-private-1678980932-back                                                      
  vm-untrusted-private-1678980932-back               qubes_dom0 Vwi---tz--   42.00g pool00                                                                                           
  vm-untrusted-private-snap                          qubes_dom0 Vwi---tz--   42.00g pool00 vm-untrusted-private                                                                      
  vm-untrusted-root-snap                             qubes_dom0 Vwi---tz--   20.00g pool00 vm-debian-11-root-1679130937-back                                                         
  vm-untrusted-volatile                              qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-videokonferenz-private                          qubes_dom0 Vwi---tz--    2.00g pool00 vm-videokonferenz-private-1621252915-back                                                 
  vm-videokonferenz-private-1621252915-back          qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-whonix-gw-16-private                            qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-whonix-gw-16-root-1679305216-back               qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
  vm-whonix-ws-15-dvm-private                        qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-whonix-ws-16-private                            qubes_dom0 Vwi---tz--    2.00g pool00                                                                                           
  vm-whonix-ws-16-root                               qubes_dom0 Vwi---tz--   10.00g pool00 vm-whonix-ws-16-root-1674925902-back                                                      
  vm-whonix-ws-16-root-1674925902-back               qubes_dom0 Vwi---tz--   10.00g pool00                                                                                           
