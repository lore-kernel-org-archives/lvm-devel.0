From: Milan Broz <mbroz@redhat.com>
Date: Tue, 17 Mar 2009 13:24:29 +0100
Subject: [PATCH] pvcreate: conditionally wipe swap signatures
In-Reply-To: <87tz5tl2jb.fsf@eriador.mornfall.net>
References: <87tz5tl2jb.fsf@eriador.mornfall.net>
Message-ID: <49BF967D.9060702@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:
> 
> this should address https://bugzilla.redhat.com/show_bug.cgi?id=443062 -- the
> first patch implements the actual check, in the spirit of dev_is_md (it also
> gets a check in the testsuite). The code is based on swap signature detection
> in swapon implementation of util-linux-ng:
> http://git.kernel.org/?p=utils/util-linux-ng/util-linux-ng.git;a=blob_plain;f=mount/swapon.c
> 
> The latter patch just throws in some checks that the old code misses. They
> might as well be redundant (or not, depends on how you look at it). Personally,
> I am ambivalent -- advice about (non-)inclusion sought.

Reviewed-by: Milan Broz <mbroz@redhat.com>
Tested-by: Milan Broz <mbroz@redhat.com>

Milan
--
mbroz at redhat.com


nit-picking mode:

+int dev_is_swap(struct device *dev, uint64_t *signature)
+{
+	char buf[10];

why not char buf[SIGNATURE_SIZE]; ?



