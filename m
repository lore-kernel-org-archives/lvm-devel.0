From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 2 Apr 2009 16:13:11 -0400
Subject: Re: [RFC PATCH 0/7] Introduce metadata cache feature
In-Reply-To: <49D4F38B.9090705@redhat.com>
References: <49D4F38B.9090705@redhat.com>
Message-ID: <20090402201311.GA8492@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 02 2009 at  1:19pm -0400,
Takahiro Yasui <tyasui@redhat.com> wrote:

> Hi,
> 
> This patch set introduces the metadata cache feature to reduce I/Os issued
> by lvm commands. This is still prototype and is not even fully tested, but
> let me post it to discuss its design and implementation.
> 
> Any comments and suggestions are welcome.
> 
> 
> PATCH SET
> =========
> 
>   1/7: remove device scan from _text_create_text_instance
>   2/7: rename _has_scanned to _need_scan
>   3/7: separate metadata parse and verification
>   4/7: support metadata cache feature
>   5/7: add metadata cache interface
>   6/7: individual lvm command settings
>   7/7: introduce metadata cache feature
> 
> 
> BACKGROUND
> ==========
> 
> In the current implementation of lvm commands, all devices except for
> devices filtered by configuration are scanned every time lvm commands
> are executed. Information of physical volume, volume group and logical
> volume are stored only in the metadata area on each real devices, and
> reading these metadata from devices are required in order to figure out
> the lvm structure in the system and to check their consistency. This
> implementation provides high reliability.
> 
> On the other hand, device scan is done every time lvm commands are
> executed, and many "READ I/O" are issued to those devices. This behavior
> causes the following problems.
> 
> * Command execution time
> 
>   Each lvm command scans all devices even though devices don't belong to
>   the target logical volume (LV) and volume group (VG) and not related
>   to the operation. This may cause a long operation time.
> 
>   For example, on the system with 1000 physical volumes (PV) and VG (vg0)
>   composed of PV(pv0), the lvm command, 'vgdisplay vg0', scans 1000 PVs
>   and issues READ I/Os to all PVs. In this case, accessing only to pv0
>   by vgdisplay is desirable.
> 
> * Maintenance issues
> 
>   Once a device got problems and replied no response, each lvm command
>   will be timed-out even if the target devices are not broken, and lvm
>   commands take much longer to be completed. This prevents quick system
>   maintenance and recovery.
> 
> * Blockage of mirrored structure
> 
>   Once I/O errors are detected by device-mapper in the kenrnel and are
>   noticed to dmeventd, it handles failure recovery. In case of an error
>   on mirrored volume, dmeventd calls lvm command (vgreduce) internally
>   and tries to remove bad volumes. Here, vgreduce scans all PVs. If
>   there is a bad device which is not related to the mirror and causes
>   timeout for I/Os, blockage process takes a long time and stops user
>   applications during the long recovery.
> 
> Accessing only to target devices by lvm commands are strongly required.
> This prototype patch solves the first two issues now, but the last issue
> has not been covered yet.
> 
> 
> DESIGN OVERVIEW
> ===============
> 
> * Fill lvmcache using metadata cache
> 
>   In the current lvmcache implementation, device scan is not generally
>   triggered when requested information is on lvmcache. To meet this
>   condition, metadata cache files are read from cache directory and
>   loaded into lvmcache before the command specific functions are
>   executed.
> 
>   In addition, the CACHE_INVALID flag is set to cache data when metadata
>   cache is loaded into lvmcache so that the cache should be verified
>   when it is accessed.
> 
> * Separate metadata parse and device verification
> 
>   In the current implementation, parse and verification process are
>   done together in _reav_pv function. When physical volume is parsed
>   in the metadata area, devices related physical volumes are accessed
>   and verified.
> 
>   To utilize the parse functions, _read_vg and _read_pv, by metadata
>   cache feature, device verification procedures are removed out of
>   metadata parse functions, and merged into post procedures. When parse
>   is done, the DEV_NEED_VERIFY flag is set to the device structures
>   so that devices will be verified later.
> 
> * Use text metadata format as cache file
> 
>   lvm commands have already functions to read and write metadata into
>   text files in the specified directory, which are used by backup or
>   archive. The metadata cache feature handles cache files of the same
>   format with these functions.


Hello Taka,

I read through this introductory email and I think that your work
clearly offers a long overdue fix to some fundamental flaws in the lvm
tools' algorithms associated with metadata.  Thanks for doing this
work.  That being said, I've not reviewed the code (yet).

> 
> CONFIG SETTING
> ==============
> 
> The "backup/metadata_cache" parameter is added in the lvm configuration
> file, lvm.conf, to enable and disable this metadata cache feature.
> 
> * lvm.conf
> 
>   backup {
>       ....
>       metadata_cache = 1   # enable
>   }

...

> FUTURE WORKS
> ============
...
> * Add commandline option
> 
>   Add a new commandline option (ex --metadatacache y|n) to enable and
>   disable cache feature in order to override a setting of the lvm
>   configuration file.

You should already be able to achieve that with:

<lvm_command> ... --config 'backup{metadata_cache=1}'
or
<lvm_command> ... --config 'backup{metadata_cache=0}'


Mike


