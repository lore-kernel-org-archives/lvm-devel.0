From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Mon, 8 Feb 2010 17:09:18 -0800
Subject: [PATCH 0 of 12] LVM add 'mirrored' log type
In-Reply-To: <4B70AC42.90701@redhat.com>
References: <1265402083.14189.2.camel@hydrogen.msp.redhat.com>
	<4B70AC42.90701@redhat.com>
Message-ID: <20100209010918.GA6158@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui [tyasui at redhat.com] wrote:
> On 02/05/10 15:34, Jonathan Brassow wrote:
> > The following set of patches adds the 'mirrored' log type.  It differs
> > from the last batch by changing the name of the log type
> > (s/redundant/mirrored/), fixing all the issues uncovered by the
> > testsuite, adding new test cases, and including log monitoring (provided
> > by Malahal Naineni).
> 
> I'm testing the patch set, but a log monitoring doesn't work properly.
> When dmeventd detects an error, lvconvert is executed for its repair.
> For example, in case that the mirror VG/LV name is vg00/lv00, lvconvert
> was called with the following options:
> 
> lvconvert --config devices{ignore_suspended_devices=1} --repair \
>           --use-policies vg00/lv00_mlog
> 
> However, lvconvert can't accept vg00/lv00_mlog because "_mlog" is
> an reserved name. When lvconvert is executed by itself, the following
> message is displayed, and no repair is done.
> 
> # lvconvert --repair vg00/lv00_mlog
>   Names including "_mlog" are reserved. Please choose a different LV name.
>   Run `lvconvert --help' for more information.
> 
> We need to escape from this restriction when "mirrored" log is used.

I used an older LVM where it failed to convert a normal mirror. I used
"vgreduce" and it worked fine. So I used "vgreduce" to test the 'mlog'
conversion too. The actual command I used is constructed from the
following code piece:

snprintf(cmd_str, CMD_SIZE, "vgreduce --removemissing --force %s", vg)

I will test with the latest LVM and fix it. Thank you.

--Malahal.


