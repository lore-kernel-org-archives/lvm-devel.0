From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 19 May 2017 04:05:20 +0100
Subject: Wrong locking type on local VG when clvm is used?
In-Reply-To: <d24e1f13-4a0c-71f7-a4cb-bc3c7fda3bb7@suse.com>
References: <d24e1f13-4a0c-71f7-a4cb-bc3c7fda3bb7@suse.com>
Message-ID: <20170519030520.GB15801@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, May 19, 2017 at 10:46:09AM +0800, Eric Ren wrote:
> Looking a bit at the code, LVM decides the locking_type on command basis, i.e. wrapping
> the command around with init_locking() and fin_locking(). So, I'm thinking if we can change
> locking_type selection to VG basis. For example, "vgchange -ay local_vg cluster_vg", we can
> decide the locking_type for each VG. Well, it's overkill if all the VGs are either local, or
> cluster... Is this reasonable, or something worth to do?

Probably not - it's not really worth that level of complexity - we
considered it several times before but always ruled it out.  (We did
tackle part of the difficulty when introducing lvmlockd though.)  The
workaround is easy - you already found one - and I thought the case you
described used to work anyway (if the daemon couldn't find the object
referenced it used to trigger a scan so it would find it) so it might
just be needing some bug fix or varied configuration setting. 

Alasdair


