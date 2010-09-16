From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 15 Sep 2010 22:39:18 -0400
Subject: LVM2/test t-pvcreate-operation-md.sh
In-Reply-To: <20100821154346.11816.qmail@sourceware.org>
Message-ID: <20100916023917.GA29343@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Aug 21 2010 at 11:43am -0400,
snitzer at sourceware.org <snitzer@sourceware.org> wrote:

> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	snitzer at sourceware.org	2010-08-21 15:43:45
> 
> Modified files:
> 	test           : t-pvcreate-operation-md.sh 
> 
> Log message:
> 	Verify that pvcreate --dataalignment really does override the topology
> 	detected alignment.
> 	
> 	NOTE: lvm2 doesn't detect MD 1.2 metadata (now the default on RHEL6) so
> 	for now I'm forcing 1.0 metadata.  This was needed to be able to reuse
> 	the existing loop devices but recreate the md device with different
> 	raid0 striping.

Turns out there is nothing wrong with LVM2's MD 1.x superblock
detection (1.0, 1.1, and 1.2 are detected perfectly).

I figured out why using MD v1.0 metadata worked for this most recently
added test though:

MD's v1.0 superblock is placed at the end of the disk.  v1.1 and v1.2
are placed at the beginning of the disk.

If v1.1 or v1.2 superblock are used then the partition table of the
previous MD v1.2 device is preserved.

But when an MD v1.0 superblock is used for this new test it allows
pvcreate of the new MD v1.0 device to overwrite the partition table of
the previous v1.2 MD device.

Otherwise, if/when v1.1 or v1.2 superblock are used, for the new MD
device, you get (the failure that caused me to force the use of v1.0):

#device/dev-cache.c:329         /dev/md/md_lvm_test0: Added to device cache
#device/dev-io.c:487         Opened /dev/md/md_lvm_test0 RO
#device/dev-io.c:260       /dev/md/md_lvm_test0: size is 131072 sectors
#device/dev-io.c:134         /dev/md/md_lvm_test0: block size is 4096 bytes
#filters/filter.c:167         /dev/md/md_lvm_test0: Skipping: Partition table signature found
#device/dev-io.c:533         Closed /dev/md/md_lvm_test0


> --- LVM2/test/t-pvcreate-operation-md.sh	2010/08/12 04:56:05	1.9
> +++ LVM2/test/t-pvcreate-operation-md.sh	2010/08/21 15:43:45	1.10
> @@ -41,13 +41,17 @@
>  	sleep 2
>  	rm -f $mddev
>      fi
> +}
> +
> +cleanup_md_and_teardown() {
> +    cleanup_md
>      teardown
>  }
>  
>  # create 2 disk MD raid0 array (stripe_width=128K)
>  test -b "$mddev" && exit 200
> -mdadm --create $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 $dev1 $dev2
> -trap 'aux cleanup_md' EXIT # cleanup this MD device at the end of the test
> +mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 $dev1 $dev2
> +trap 'aux cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
>  test -b "$mddev" || exit 200
>  
>  # Test alignment of PV on MD without any MD-aware or topology-aware detection
> @@ -113,3 +117,27 @@
>  	pvremove $mddev_p
>      fi
>  fi
> +
> +# Test newer topology-aware alignment detection w/ --dataalignment override
> +if [ $linux_minor -ge 33 ]; then
> +    cleanup_md
> +    pvcreate -f $dev1
> +    pvcreate -f $dev2
> +
> +    # create 2 disk MD raid0 array (stripe_width=2M)
> +    test -b "$mddev" && exit 200
> +    mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 1024 $dev1 $dev2
> +    test -b "$mddev" || exit 200
> +
> +    # optimal_io_size=2097152, minimum_io_size=1048576
> +    pv_align="2.00m"
> +    pvcreate --metadatasize 128k \
> +	--config 'devices { md_chunk_alignment=0 }' $mddev
> +    check_pv_field_ $mddev pe_start $pv_align
> +
> +    # now verify pe_start alignment override using --dataalignment
> +    pv_align="192.00k"
> +    pvcreate --dataalignment 64k --metadatasize 128k \
> +	--config 'devices { md_chunk_alignment=0 }' $mddev
> +    check_pv_field_ $mddev pe_start $pv_align
> +fi


