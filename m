From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 10 Mar 2010 14:31:38 -0500
Subject: [DRACUT PATCH] lvm_scan: use '--ignoremonitoring' rather than '--monitor n'
In-Reply-To: <1268249058-23510-1-git-send-email-snitzer@redhat.com>
References: <1268249058-23510-1-git-send-email-snitzer@redhat.com>
Message-ID: <20100310193138.GA13399@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 10 2010 at  2:24pm -0500,
Mike Snitzer <snitzer@redhat.com> wrote:

> lvchange and vgchange '--monitor n' will not prevent lvm from
> attempting to dlopen the libdevmapper-event library.
> 
> dracut git commit 47ab3b6c5e introduced the use of '--monitor n' but
> '--ignoremonitoring' is needed now that the libdevmapper-event library
> isn't copied into the initramfs (ever since 0fae59d6eb3)

And just to be clear:
'--monitor n' is "stop monitoring this (VG or LV)"
'--ignoremonitoring' is "don't do any monitoring".

We'll be fixing up lvm's vgchange and lvchange man pages so that they
are more precise on what '--monitor n' means.

Mike


