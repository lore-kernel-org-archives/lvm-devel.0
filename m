From: Daniel Moessner <dmoessne@redhat.com>
Date: Sun, 10 Feb 2019 11:30:25 +0100
Subject: Is a service restart needed when vg profile is changed ?
Message-ID: <ae8959fb-6a91-9953-7264-e83c9fc36153@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I am a bit uncertain if changes in a lvm profile need a restart of lvm 
service.
I do have a profile ` /etc/lvm/profile/myvg--my-pool-extend.profile` 
whth the following content:
~~~
activation {
 ??? thin_pool_autoextend_threshold=75
 ??? thin_pool_autoextend_percent=30

}
~~~

and wonder if I change these values, if they are automatically applied 
or a service needs restarted.

lvm.conf(5) states:
~~~
lvm.conf is loaded during the initialisation phase of lvm(8). This file 
can in turn lead to other files being loaded -
settings read in later override earlier settings.? File timestamps are 
checked between commands and if any
have changed, all the files are reloaded.
~~~

so does this apply to profile files as well and is the timestamp change 
also be caught up by dmeventd ?

Thanks,
daniel


