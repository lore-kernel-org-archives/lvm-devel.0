From: Marian Csontos <mcsontos@redhat.com>
Date: Fri, 16 May 2014 13:59:53 +0200
Subject: master - man: lvmcache
In-Reply-To: <20140515101423.D1A8660DC4@fedorahosted.org>
References: <20140515101423.D1A8660DC4@fedorahosted.org>
Message-ID: <5375FDB9.4080705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Kabi, what about running `git add lvmcache.7.in` too ?

make works, make install does not.

-- Martian


On 05/15/2014 12:14 PM, Zdenek Kabelac wrote:
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b73a78675576c562b8bf510d16dab8a35bf4cb02
> Commit:        b73a78675576c562b8bf510d16dab8a35bf4cb02
> Parent:        11bedf1baf6dbc48c7abf9a14f8584d996d00a59
> Author:        Zdenek Kabelac <zkabelac@redhat.com>
> AuthorDate:    Thu May 15 12:06:18 2014 +0200
> Committer:     Zdenek Kabelac <zkabelac@redhat.com>
> CommitterDate: Thu May 15 12:13:24 2014 +0200
>
> man: lvmcache
>
> Migrate cache description into  man(7) entry
> (like lvmthin).
> ---
>   WHATS_NEW         |    1 +
>   man/Makefile.in   |   11 ++-
>   man/lvm.8.in      |  189 +---------------------------------------------------
>   spec/packages.inc |    1 +
>   4 files changed, 13 insertions(+), 189 deletions(-)
>
> diff --git a/WHATS_NEW b/WHATS_NEW
> index 5900bc6..72834a8 100644
> --- a/WHATS_NEW
> +++ b/WHATS_NEW
> @@ -1,5 +1,6 @@
>   Version 2.02.107 -
>   ==================================
> +  Move cache description from lvm(8) to lvmcache(7) man page.
>     Display skipped prompt in silent mode.
>     Make reporting commands show help about possible sort keys on '-O help'.
>     Add metadata_percent to lvs_cols.
> diff --git a/man/Makefile.in b/man/Makefile.in
> index c6a27d0..dd59555 100644
> --- a/man/Makefile.in
> +++ b/man/Makefile.in
> @@ -41,6 +41,7 @@ LVMETAD =
>   endif
>
>   MAN5=lvm.conf.5
> +MAN7=
>   MAN8=lvm-dumpconfig.8 \
>   	lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
>   	lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \
> @@ -61,10 +62,12 @@ ifeq ("@BUILD_CMIRRORD@", "yes")
>     MAN8CLUSTER+=cmirrord.8
>   endif
>
> +ifneq ("@CACHE@", "none")
> +  MAN7+=lvmcache.7
> +endif
> +
>   ifneq ("@THIN@", "none")
> -  MAN7=lvmthin.7
> -else
> -  MAN7=
> +  MAN7+=lvmthin.7
>   endif
>
>   MAN8DM=dmsetup.8 $(DMEVENTDMAN)
> @@ -75,7 +78,7 @@ MAN8DIR=$(mandir)/man8
>   MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
>
>   CLEAN_TARGETS=$(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(MAN8DM)
> -DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8 dmeventd.8 lvmthin.7 blkdeactivate.8
> +DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8 dmeventd.8 lvmcache.7 lvmthin.7 blkdeactivate.8
>
>   include $(top_builddir)/make.tmpl
>
> diff --git a/man/lvm.8.in b/man/lvm.8.in
> index e1063c6..41223b0 100644
> --- a/man/lvm.8.in
> +++ b/man/lvm.8.in
> @@ -406,191 +406,8 @@ a command.
>   Some logical volume types are simple to create and can be done with a
>   single \fBlvcreate\fP(8) command.  The linear and striped logical
>   volume types are an example of this.  Other logical volume types may
> -require more than one command to create.  The cache and thin provisioning
> -types are examples of this.
> -
> -.br
> -.SS Cache
> -The \fIcache\fP logical volume type uses a small and fast LV to improve
> -the performance of a large and slow LV.  It does this by storing the
> -frequently used blocks on the faster LV.
> -LVM refers to the small fast LV as a \fBcache pool LV\fP.  The large
> -slow LV is called the \fBorigin LV\fP.  Due to requirements from dm-cache
> -(the kernel driver), LVM further splits the cache pool LV into two
> -devices - the \fBcache data LV\fP and \fBcache metadata LV\fP.  The cache
> -data LV is where copies of data blocks are kept from the
> -origin LV to increase speed.  The cache metadata LV holds the
> -accounting information that specifies where data blocks are stored (e.g.
> -on the origin LV or on the cache data LV).  Users should be familiar with
> -these LVs if they wish to create the best and most robust cached
> -logical volumes.
> -
> -.SS Cache Terms
> -.nf
> -origin LV           OriginLV      large slow LV
> -cache data LV       CacheDataLV   small fast LV for cache pool data
> -cache metadata LV   CacheMetaLV   small fast LV for cache pool metadata
> -cache pool LV       CachePoolLV   CacheDataLV + CacheMetaLV
> -cache LV            CacheLV       OriginLV + CachePoolLV
> -.fi
> -
> -.SS Cache Steps
> -The steps to create a logical volume of \fIcache\fP type are as follows:
> -.TP
> -0.
> -Create an LV or identify an existing LV to be the origin LV.
> -.TP
> -1.
> -Create the cache data LV.  The size of this LV is the size of the cache
> -and will be reported as the size of the cache pool LV.
> -.TP
> -2.
> -Create the cache metadata LV.
> -The size of this LV should be 1000 times smaller than the cache data LV
> -with a minimum size of 8MiB.
> -.TP
> -3.
> -Create the cache pool LV by combining the cache data LV (from step 1)
> -and cache metadata LV (from step 2).  When performing this step,
> -behavioral characteristics of the cache pool LV can be set.
> -The name of the cache pool LV takes the name of the cache data LV and
> -the cache data LV and cache metadata LV are renamed
> -to CachePoolLV_cdata and CachePoolLV_cmeta.
> -.TP
> -4.
> -Create a cache LV by linking the cache pool LV to the origin LV.
> -The user accessible cache LV takes the name of the origin LV,
> -while the origin LV becomes a hidden LV with the name
> -OriginLV_corig.  Users can perform this step while the origin LV
> -is in use.
> -
> -.P
> -The steps above represent the best way to create a cache LV.
> -They provide the most options and have the ability to create the
> -most robust logical volumes.  The examples below illustrate how these
> -steps might be used in practice.
> -
> -.SS Cache Commands
> -.nf
> -0. create OriginLV
> -lvcreate -L LargeSize -n OriginLV VG SlowPVs
> -
> -1. create CacheDataLV
> -lvcreate -L CacheSize -n CacheDataLV VG FastPVs
> -
> -2. create CacheMetaLV
> -lvcreate -L MetaSize -n CacheMetaLV VG FastPVs
> -
> -3. create CachePoolLV
> -lvconvert --type cache-pool --poolmetadata VG/CacheMetaLV VG/CacheDataLV
> -CachePoolLV takes the name of CacheDataLV.
> -CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
> -CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
> -
> -4. create CacheLV
> -lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
> -CacheLV takes the name of OriginLV.
> -OriginLV is renamed OriginLV_corig and becomes hidden.
> -.fi
> -
> -.SS Cache Examples
> -
> -.B Example 1:
> -Creating a simple cache LV.
> -.br
> -
> -.nf
> -0. Create the origin LV
> -# lvcreate -L 10G -n lvx vg /dev/slow_dev
> -
> -1. Create a cache data LV
> -# lvcreate -L 1G -n lvx_cache vg /dev/fast_dev
> -
> -2. Create a cache metadata LV (~1/1000th size of CacheDataLV or 8MiB)
> -# lvcreate -L 8M -n lvx_cache_meta vg /dev/fast_dev
> -
> -3. Create a cache pool LV, combining cache data LV and cache metadata LV
> -# lvconvert --type cache-pool --poolmetadata vg/lvx_cache_meta \\
> -	vg/lvx_cache
> -
> -4. Create a cached LV by combining the cache pool LV and origin LV
> -# lvconvert --type cache --cachepool vg/lvx_cache vg/lvx
> -.fi
> -
> -.B Example 2:
> -Creating a cache LV with a fault tolerant cache pool LV.
> -
> -Users who are concerned about the possibility of failures in their fast devices
> -that could lead to data loss might consider making their cache pool sub-LVs
> -redundant.  Example 2 illustrates how to do that.  Note that only steps
> -1 & 2 change.
> -
> -.nf
> -0. Create an origin LV we wish to cache
> -# lvcreate -L 10G -n lvx vg /dev/slow_devs
> -
> -1. Create a 2-way RAID1 cache data LV
> -# lvcreate --type raid1 -m 1 -L 1G -n lvx_cache vg \\
> -	/dev/fast1 /dev/fast2
> -
> -2. Create a 2-way RAID1 cache metadata LV
> -# lvcreate --type raid1 -m 1 -L 8M -n lvx_cache_meta vg \\
> -	/dev/fast1 /dev/fast2
> -
> -3. Create a cache pool LV combining cache data LV and cache metadata LV
> -# lvconvert --type cache-pool --poolmetadata vg/lvx_cache_meta \\
> -	vg/lvx_cache
> -
> -4. Create a cached LV by combining the cache pool LV and origin LV
> -# lvconvert --type cache --cachepool vg/lvx_cache vg/lvx
> -.fi
> -
> -.B Example 3:
> -Creating a simple cache LV with \fIwritethough\fP caching.
> -
> -Some users wish to ensure that any data written will be stored both in the
> -cache pool LV and on the origin LV.  The loss of a device associated with
> -the cache pool LV in this case would not mean the loss of any data.  When
> -combining the cache data LV and the cache metadata LV to form the cache pool
> -LV, properties of the cache can be specified - in this case,
> -\fIwritethrough\fP vs. \fIwriteback\fP.  Note that only step 3 is affected
> -in this case.
> -
> -.nf
> -0. Create an origin LV we wish to cache (yours may already exist)
> -# lvcreate -L 10G -n lvx vg /dev/slow
> -
> -1. Create a cache data LV
> -# lvcreate -L 1G -n lvx_cache vg /dev/fast
> -
> -2. Create a cache metadata LV
> -# lvcreate -L 8M -n lvx_cache_meta vg /dev/fast
> -
> -3. Create a cache pool LV specifying cache mode "writethrough"
> -# lvconvert --type cache-pool --poolmetadata vg/lvx_cache_meta \\
> -	--cachemode writethrough vg/lvx_cache
> -
> -4. Create a cache LV by combining the cache pool LV and origin LV
> -# lvconvert --type cache --cachepool vg/lvx_cache vg/lvx
> -.fi
> -
> -.SS Removing Cache Logical Volumes
> -If you wish to remove all logical volumes associated with a cache
> -LV, you must remove both top-level, user-visible devices.
> -The cache metadata LV and cache data LV cannot be removed
> -directly.  If only the cache pool LV is specfied for removal, any cached
> -blocks not yet on the origin LV will be flush, the cache pool LV will be
> -removed, and the now un-cached origin LV will remain.  If the user
> -specifies a cache LV for removal, then the origin LV is
> -removed and only the cache pool LV will remain.  The cache pool LV can then
> -be used to create another cache LV with a different origin LV if desired.
> -
> -When users intend to remove all logical volumes associated with a
> -cache LV, it is generally better to start with the origin LV and then
> -remove the cache pool LV.  If the operations are performed in the
> -reverse order, the user will have to wait for the contents of the
> -cache pool LV to be flushed before the origin LV is removed.  This
> -could take some time.
> +require more than one command to create.  The cache (\fBlvmcache\fP(7))
> +and thin provisioning (\fBlvmthin\fP(7)) types are examples of this.
>
>   .SH DIAGNOSTICS
>   All tools return a status code of zero on success or non-zero on failure.
> @@ -600,6 +417,8 @@ All tools return a status code of zero on success or non-zero on failure.
>   .I $HOME/.lvm_history
>   .SH SEE ALSO
>   .BR lvm.conf (5),
> +.BR lvmcache (7),
> +.BR lvmthin (7),
>   .BR lvm\ dumpconfig (8),
>   .BR clvmd (8),
>   .BR lvchange (8),
> diff --git a/spec/packages.inc b/spec/packages.inc
> index 16b90e0..5999ab7 100644
> --- a/spec/packages.inc
> +++ b/spec/packages.inc
> @@ -83,6 +83,7 @@ fi
>    %{_sbindir}/lvmetad
>   %endif
>   %{_mandir}/man5/lvm.conf.5.gz
> +%{_mandir}/man7/lvmcache.7.gz
>   %{_mandir}/man7/lvmthin.7.gz
>   %{_mandir}/man8/fsadm.8.gz
>   %{_mandir}/man8/lvchange.8.gz
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


