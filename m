From: rath@mglug.de <rath@mglug.de>
Date: Fri, 20 Sep 2013 16:24:51 +0200
Subject: thinpool creation set links /dev/vgname/lvname to /dev/mapper again instead to /dev/dm-X
Message-ID: <afe74e531402fe71d2c999f16c79e216@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 Hi list,

 i have a strange effect in thinpool creation (_not_ devices _from 
 existing_ thinpool):

 creating a thinpool works, but the appropriate link isnt created.

 What I have done:

 Installed a xubuntu-12.04.3 64bit with linux-image-generic-lts-raring 
 (3.8.0-30)
 taken the last git (today, v101)
 compiled with ./configure --enable-udev_sync --enable-udev_rules \
                           --with-thin=internal 
 --with-replicators=internal

 Installed the udev-rules into /lib/udev:

 root at dmicrash:/lib/udev/rules.d# ls /lib/udev/rules.d/
 10-dm.rules               60-persistent-input.rules          
 75-probe_mtd.rules
 11-dm-lvm.rules           60-persistent-serial.rules         
 75-tty-description.rules
 13-dm-disk.rules          60-persistent-storage.rules        
 78-graphics-card.rules
 40-ia64.rules             60-persistent-storage-tape.rules   
 78-sound-card.rules
 40-ppc.rules              60-persistent-v4l.rules            
 80-drivers.rules
 42-qemu-usb.rules         61-accelerometer.rules             
 95-dm-notify.rules
 50-firmware.rules         70-udev-acl.rules                  
 95-keyboard-force-release.rules
 50-udev-default.rules     75-cd-aliases-generator.rules      
 95-keymap.rules
 60-cdrom_id.rules         75-net-description.rules           
 95-udev-late.rules
 60-persistent-alsa.rules  75-persistent-net-generator.rules  README


 The settings in /etc/lvm/lvm.conf are:

 devices {
     dir = "/dev"
     scan = [ "/dev" ]
     obtain_device_list_from_udev = 1
 
     preferred_names = [ ]
     filter = [ "a/.*/" ]
     cache_dir = "/etc/lvm/cache"
     cache_file_prefix = ""
     write_cache_state = 1
     sysfs_scan = 1
     md_component_detection = 1
     md_chunk_alignment = 1
     data_alignment_detection = 1
     data_alignment = 0
     data_alignment_offset_detection = 1
     ignore_suspended_devices = 0
 }
 log {
     verbose = 0
     syslog = 1
     overwrite = 0
     level = 0
     indent = 1
     command_names = 0
     prefix = "  "
 }
 backup {
     backup = 1
     backup_dir = "/etc/lvm/backup"
     archive = 1
     archive_dir = "/etc/lvm/archive"
     retain_min = 10
     retain_days = 30
 }
 shell {
     history_size = 100
 }
 global {
     umask = 077
     test = 0
     units = "h"
     si_unit_consistency = 1
     activation = 1
     proc = "/proc"
     locking_type = 1
     wait_for_locks = 1
     fallback_to_clustered_locking = 1
     fallback_to_local_locking = 1
     locking_dir = "/var/lock/lvm"
     prioritise_write_locks = 1
     abort_on_internal_errors = 0
 }
 activation {
     checks = 0
     udev_sync = 1
     auto_set_activation_skip = 0
     udev_rules = 1
     verify_udev_operations = 1
     missing_stripe_filler = "error"
     reserved_stack = 256
     reserved_memory = 8192
     process_priority = -18
     mirror_region_size = 512
     readahead = "auto"
     mirror_log_fault_policy = "allocate"
     mirror_image_fault_policy = "remove"
     use_mlockall = 0
     monitoring = 1
     polling_interval = 15
 }
 dmeventd {
     mirror_library = "libdevmapper-event-lvm2mirror.so"
     snapshot_library = "libdevmapper-event-lvm2snapshot.so"
 }

 You see, "verify_udev_operations" is enabled.
 Now if I create a thinpool, following happens:

 root at dmicrash:/lib# lvcreate --size 400G  -T dmivg/mythinpool
   /dev/mapper/dmivg-lvol0 not set up by udev: Falling back to direct 
 node creation.
   The link /dev/dmivg/lvol0 should have been created by udev but it was 
 not found. Falling back to direct link creation.
   Logical volume "lvol0" created
   Node /dev/mapper/dmivg-lvol0 was not removed by udev. Falling back to 
 direct node removal.
   /dev/mapper/dmivg-mythinpool not set up by udev: Falling back to 
 direct node creation.
   The link /dev/dmivg/lvol0 should have been removed by udev but it is 
 still present. Falling back to direct link removal.
   The link /dev/dmivg/mythinpool should have been created by udev but 
 it was not found. Falling back to direct link creation.
   Logical volume "mythinpool" created
   /dev/mapper/dmivg-mythinpool_tmeta not set up by udev: Falling back 
 to direct node creation.
   /dev/mapper/dmivg-mythinpool_tdata not set up by udev: Falling back 
 to direct node creation.
   /dev/mapper/dmivg-mythinpool-tpool not set up by udev: Falling back 
 to direct node creation.
 root at dmicrash:/lib# ls -l /dev/dmivg/
 insgesamt 0
 lrwxrwxrwx 1 root root  7 Sep 20 15:59 linuxpool -> ../dm-0
 lrwxrwxrwx 1 root root 28 Sep 20 16:21 mythinpool -> 
 /dev/mapper/dmivg-mythinpool
 root at dmicrash:/lib# lvremove -f /dev/dmivg/mythinpool
   Logical volume "mythinpool" successfully removed
   Node /dev/mapper/dmivg-mythinpool was not removed by udev. Falling 
 back to direct node removal.
   Node /dev/mapper/dmivg-mythinpool-tpool was not removed by udev. 
 Falling back to direct node removal.
   Node /dev/mapper/dmivg-mythinpool_tdata was not removed by udev. 
 Falling back to direct node removal.
   Node /dev/mapper/dmivg-mythinpool_tmeta was not removed by udev. 
 Falling back to direct node removal.
   The link /dev/dmivg/mythinpool should have been removed by udev but 
 it is still present. Falling back to direct link removal.
 root at dmicrash:/lib# ls -l /dev/dmivg/
 insgesamt 0
 lrwxrwxrwx 1 root root 7 Sep 20 15:59 linuxpool -> ../dm-0



 I put the same commands with -vvvv into a pastebin:

 root at dmicrash:/lib# lvcreate -vvvv --size 400G  -T dmivg/mythinpool |& 
 pastebinit
 http://paste.ubuntu.com/6132895/
 root at dmicrash:/lib# lvremove -f /dev/dmivg/mythinpool ^C
 root at dmicrash:/lib# lvremove -vvvv -f /dev/dmivg/mythinpool |& 
 pastebinit
 http://paste.ubuntu.com/6132897/


 What must I do, that the link /dev/dmivg/mythinpool points directly to 
 /dev/dm-X ?

 Tfh!
 Oliver


