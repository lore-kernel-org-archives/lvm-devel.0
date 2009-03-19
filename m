From: Sandeep K Sinha <sandeepksinha@gmail.com>
Date: Thu, 19 Mar 2009 17:04:28 +0530
Subject: liblvm IOCTL/sysfs interface
Message-ID: <37d33d830903190434o563ef7a1l7219f87388fbf2da@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

I  would like to know if there is any means currently to know the complete
geometry of a LVM volume.
e.g, If a volume has 3 PV(targets).

So, we should be able to extract some information like.

Name of Volume.
Name of Volume Group.
Name, Range and size for each of the Physical devices involved.

I execute the following steps.

1. pvcreate /dev/sda5 /dev/sda6
2. vgcreate vg /dev/sda5 /dev/sda6
3. lvcreate vg -L 5G

So, I should see the information like.

lvol0
vg
target1 - /dev/sda5 ----  0 -- 10000 ( BEGIN  -- Length )
target2 - /dev/sda6 ----  10001 -- 4000


We do maintain these informations inside the kernel, We should atleast
have an ioctl or sysfs based interface to extract
these information.

Liblvm is under development, won't it be of a good use to provide such
a functionality.

kindly suggest !

-- 
Regards,
Sandeep.





 	
?To learn is to change. Education is a process that changes the learner.?


