From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 21 Sep 2011 12:22:37 +0200
Subject: [PATCH 8/7][retry remove] Also add check for filesystem use on a DM/LVM device - "dm_device_has_fs"
In-Reply-To: <4E79A68D.1080702@redhat.com>
References: <4E78E64C.8080006@redhat.com> <4E78F101.7090907@redhat.com>
	<4E79A68D.1080702@redhat.com>
Message-ID: <4E79BAED.20607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 21.9.2011 10:55, Milan Broz napsal(a):
> On 09/20/2011 10:01 PM, Zdenek Kabelac wrote:
>> How bad would be to replace the code in lvremove with something like:
>> when remove fails -  call  system("udevadm settle") - and retry whole
>> lv_remove_with_depenencies() (or whatever baselevel we pick here).
> 
> This solution was nacked already, please do not reiterate it again.

I haven't heard about nack yet.

> Avoid system() in any case, whatever command it is.

A lot of time has been spent squeezing seconds from execution time - and now
we add multiple seconds back when (i.e. removal of 1000LVs and several will
have problem with its removal and command might take minutes to finish...)

>> PS: easiest workaround for failing lvremove is - to replace  lvremove with
>> shell wrapper which call udevadm settle and retries lvremove in case the first
>> one fails.
> 
> Yes, and all system security audit log will point to lvm. Please do not do
> such home made solutions. This need proper solution and no such things.

Well I'm not stopping current solution - but we could have better hack here -
Also I think we could repeat the code from udevadm settle in our library in
case use of exec_cmd("udevadm settle") would be seen as a security problem.

Obviously selinux policy would need some minor mods for udev readout, but this
should not be a problem.

Zdenek


