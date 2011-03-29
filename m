From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 29 Mar 2011 20:08:23 +0900
Subject: Filtering out LVs?
Message-ID: <4D91BDA7.2030003@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

LVM2 commands scan /dev for metadata read-in and validation.
By default, it includes DM devices.

On the other hand, LV deactivation checks its open count
and fails if it's open.

So there is a race that one of multiple vgchange instances prevents other;
"vgchange -an vg0" might fail to deactivate the VG if "vgchange -an vg1"
opens vg0/lv0 at the very time for scanning.

E.g. try this:
   From one console,
     # while true; do vgscan; done
   and from other console,
     # while true; do vgchange -ay $VG; vgchange -an $VG || break; done

While device filter can be configured to avoid LV devices,
and also someone may want to use LV as PV,
it seems inconvenient default behavior.

Does it make sense to add a filter to avoid LVs?
(It has to cope with multiple udev-oriented aliases...)

-- 
Jun'ichi Nomura, NEC Corporation


