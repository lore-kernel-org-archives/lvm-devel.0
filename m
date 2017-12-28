From: Eric Ren <zren@suse.com>
Date: Thu, 28 Dec 2017 10:42:10 +0800
Subject: [PATCH 0/2] LVM2: fix lvmetad udev rules for CHANGE events
In-Reply-To: <d9c8ba0b-26b0-00c4-ff7f-12f660a763f9@suse.com>
References: <20171221115705.5055-1-mwilck@suse.com>
	<1513943697.4257.14.camel@suse.com>
	<b041c704-6f2a-b20f-c33e-a93e7504ad4d@suse.com>
	<d9c8ba0b-26b0-00c4-ff7f-12f660a763f9@suse.com>
Message-ID: <f6640724-1688-f19a-cfa1-d5b24a48432b@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,


> I tried more times. The problem doesn't occur any more. I suspect 
> maybe it's
> because there's something wrong during my manual testing - it's easy 
> to mistake
> following all those steps. I will try to put all steps into a testing 
> script for more testing.

Based on Martin's reproducing steps for x86 arch, I scripted those steps 
together into
reproducer_x86.sh in attachment. The reproducer passed 100 loops on my 
testing
machine with Martin's patches.

Please adjust some variables for your testing machine when running 
reproducer_x86.sh.
There are some ugly hard code settings inside - the device name/dev_t, 
/sys/class/scsi_host/host1/scan/,etc.

Regards,
Eric
-------------- next part --------------
A non-text attachment was scrubbed...
Name: reproducer_x86.sh
Type: application/x-shellscript
Size: 2291 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20171228/7eefcdd1/attachment.bin>
