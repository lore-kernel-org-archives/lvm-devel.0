From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 28 Feb 2007 18:39:07 +0000
Subject: Re: LVM2 ./WHATS_NEW doc/example.conf lib/commands ...
In-Reply-To: <20070228182714.26052.qmail@sourceware.org>
References: <20070228182714.26052.qmail@sourceware.org>
Message-ID: <20070228183907.GB3319@agk.surrey.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Feb 28, 2007 at 06:27:14PM -0000, agk at sourceware.org wrote:
> Log message:
> 	Move .cache file into a new /etc/lvm/cache directory by default.
> 	Add devices/cache_dir & devices/cache_file_prefix, deprecating devices/cache.
> 	Create directory in fcntl_lock_file() if required.

For the curious:

  (1) When a new file is created (.cache) it inherits the selinux context from
its directory.  So we should not have read-only configuration files (lvm.conf)
in the same directory as a read-write cache file.

  (2) I took the opportunity to change the config options available in case we
decide we want more than one cache file - it's now directory plus prefix.
 
Alasdair
-- 
agk at redhat.com


