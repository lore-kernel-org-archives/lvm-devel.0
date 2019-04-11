From: Eric Ren <renzhengeek@gmail.com>
Date: Fri, 12 Apr 2019 01:33:27 +0800
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <CAKM4Aez9H=GuRLK0EDJTwpb7j34tCu1aY4dS5_L4saDGERestg@mail.gmail.com>
References: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
	<47346a29-e6c7-6e22-4360-2d07e2ec7be3@redhat.com>
	<CAKM4Aexm31mYW8WDeiZ4shCoysCcGjic8zV0XiVqEVZvKz-ecQ@mail.gmail.com>
	<7839ff52-18e5-6a95-9a2a-12ea73457700@redhat.com>
	<CAKM4AezLrUrXZKA=vKMaRHcij3K6UBZpy-RcVXeUB9Wwfszh7Q@mail.gmail.com>
	<62151b2e-c21a-177e-f66b-e2e08857be17@redhat.com>
	<CAKM4AeyMsmqmF7NHu9-u0-86LnzrHR4Z5xNt0bmfpLJyoDE0Sw@mail.gmail.com>
	<6514b2be-67d7-3dfe-38b9-95e3bb39f55a@redhat.com>
	<CAKM4Aez9H=GuRLK0EDJTwpb7j34tCu1aY4dS5_L4saDGERestg@mail.gmail.com>
Message-ID: <CAKM4Aew6OawXaes+whH-0W-aAedR_JMF-ObYtVtowOSUdQQJ_Q@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

> Anyway - proper reproducer with full -vvvv log would be really the most
> > explanatory and needed to move on here.

The activation error is reproduced once more. Please see lvm2.log attached.

Please search the error message like this:

$grep -rn Aborting lvm2.log
./lvm2.log:1386:activate/dev_manager.c:2459 lvcreate  Aborting.  LV
mythinpool_tmeta is now incomplete and '--activationmode partial' was
not specified.

$grep -rn "Failed to suspend" lvm2.log
./lvm2.log:1399:metadata/lv_manip.c:7416 lvcreate  Failed to suspend
thin snapshot origin vg0/6.

Thanks!
Eric
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2.log
Type: application/octet-stream
Size: 301444 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190412/4e8f273f/attachment.obj>
