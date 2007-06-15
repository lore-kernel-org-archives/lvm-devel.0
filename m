From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 15 Jun 2007 12:08:47 -0400
Subject: [PATCH] allow filenames with vgcfgrestore -l
In-Reply-To: <46673CE4.4010801@redhat.com>
References: <46673CE4.4010801@redhat.com>
Message-ID: <1181923727.3687.24.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2007-06-07 at 00:01 +0100, Bryn M. Reeves wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Simple patch to permit a metadata backup file to be specified on the
> vgcfgrestore command line using -f when listing backups, for e.g.:
> 
> vgcfgrestore -l -f /tmp/VolGroup
> 
> LVM1 allowed this behavior and it's been requested a couple of times on
> the mailing list.
> 

Bryn I just checked in fixes to the vgcfgrestore man pg.  Could you take
a look and see if it is ok?




