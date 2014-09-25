From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Sep 2014 09:52:06 +0200
Subject: [PATCH] pvcreate: check the label after writing
In-Reply-To: <1411611632-2856-1-git-send-email-lzhong@suse.com>
References: <1411611632-2856-1-git-send-email-lzhong@suse.com>
Message-ID: <5423C9A6.8000304@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.9.2014 v 04:20 Lidong Zhong napsal(a):
> Some device will place metadata area at the beginning part and writing
> label may fail.Take our test for example, when running pvcreate on a CDL
> formatted DASD device(without partition), it shows successfully create
> a pv, but the label is not written on the second sector and pvs shows
> nothing. Although it is not supposed to run lvm on dasd device, it's a
> friendly behavior to check the label and return error if it fails.

Hmm - if device drive tells you - it has accepted and written some bytes
on your storage device - they really should be written there.

So IMHO driver should not lie and reject write request with error ?

Otherwise you would need to validate every single written byte by LVM ?

Maybe DASD devices should by automatically ignored by lvm filtering
as unusable device for PV  (just like i.e. too small devices)

Zdenek


