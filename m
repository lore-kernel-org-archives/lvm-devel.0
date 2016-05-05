From: Liuhua Wang <lwang@suse.com>
Date: Thu, 5 May 2016 09:38:23 +0800
Subject: [PATCH] dev-type: add support for checking sgi/sun partition table
In-Reply-To: <1459317281-15471-1-git-send-email-lwang@suse.com>
References: <1459317281-15471-1-git-send-email-lwang@suse.com>
Message-ID: <20160505013823.GA6535@wlh-host.lab.bej.apac.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Peter,

Would you please review my patch?

Thanks a lot!

Best,
Liuhua

On Wed, Mar 30, 2016 at 01:54:41PM +0800, Liuhua Wang wrote:
> The code is based on libfdisk and pass my tests.
> ---
>  lib/device/dev-type.c | 73 ++++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 61 insertions(+), 12 deletions(-)
> 
> diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
> index e1243bd..c45738f 100644
> --- a/lib/device/dev-type.c
> +++ b/lib/device/dev-type.c
> @@ -265,11 +265,13 @@ int major_is_scsi_device(struct dev_types *dt, int major)
>  	return (dt->dev_type_array[major].flags & PARTITION_SCSI_DEVICE) ? 1 : 0;
>  }
>  
> +
> +#define DEFAULT_SECTOR_SIZE 512
>  /* See linux/genhd.h and fs/partitions/msdos */
> +/* For msdos/gpt */
>  #define PART_MAGIC 0xAA55
>  #define PART_MAGIC_OFFSET UINT64_C(0x1FE)
>  #define PART_OFFSET UINT64_C(0x1BE)
> -
>  struct partition {
>  	uint8_t boot_ind;
>  	uint8_t head;
> @@ -283,6 +285,42 @@ struct partition {
>  	uint32_t nr_sects;
>  } __attribute__((packed));
>  
> +typedef struct {
> +	uint8_t skip[PART_OFFSET];
> +	struct partition part[4];
> +	uint16_t magic;
> +} __attribute__((packed)) msdos_disklabel; /* sizeof() == SECTOR_SIZE */
> +
> +/*For sun*/
> +/* See util-linux/include/pt-sun.h */
> +#define SUN_SKIP UINT64_C(0x1BC)
> +#define SUN_LABEL_MAGIC 0xDABE
> +#define SUN_MAX_PARTITIONS  8
> +typedef struct {
> +	uint8_t skip[SUN_SKIP];
> +	struct sun_partition {
> +		uint32_t start_cylinder;
> +		uint32_t num_sectors;
> +	} __attribute__((packed)) partitions[8];
> +	uint16_t magic;
> +} __attribute__((packed)) sun_disklabel;
> +
> +/*For sgi*/
> +/* See util-linux/include/pt-sgi.h */
> +#define SGI_SKIP UINIT64_C(0x134)
> +#define SGI_LABEL_MAGIC 0x0BE5A941 
> +#define SGI_MAX_PARTITIONS  16
> +typedef struct {
> +	uint32_t magic;
> +	uint8_t skip[SGI_SKIP];
> +	struct sgi_partition {
> +		uint32_t num_blocks;
> +		uint32_t first_block;
> +		uint32_t type;
> +	} __attribute__((packed)) partitions[16];
> +} __attribute__((packed)) sgi_disklabel;
> +
> +
>  static int _is_partitionable(struct dev_types *dt, struct device *dev)
>  {
>  	int parts = major_max_partitions(dt, MAJOR(dev->dev));
> @@ -303,29 +341,40 @@ static int _is_partitionable(struct dev_types *dt, struct device *dev)
>  static int _has_partition_table(struct device *dev)
>  {
>  	int ret = 0;
> +	char buf[DEFAULT_SECTOR_SIZE];
>  	unsigned p;
> -	struct {
> -		uint8_t skip[PART_OFFSET];
> -		struct partition part[4];
> -		uint16_t magic;
> -	} __attribute__((packed)) buf; /* sizeof() == SECTOR_SIZE */
> +	msdos_disklabel *msl;
> +	sun_disklabel *sunl;
> +	sgi_disklabel *sgil;
>  
>  	if (!dev_read(dev, UINT64_C(0), sizeof(buf), &buf))
>  		return_0;
>  
> -	/* FIXME Check for other types of partition table too */
> -
> -	/* Check for msdos partition table */
> -	if (buf.magic == xlate16(PART_MAGIC)) {
> +	/* Currently it supports for msdos/gpt/sgi/sun partition table */
> +	if ((msl = (msdos_disklabel *)buf) && msl.magic == xlate16(PART_MAGIC)) {
>  		for (p = 0; p < 4; ++p) {
>  			/* Table is invalid if boot indicator not 0 or 0x80 */
> -			if (buf.part[p].boot_ind & 0x7f) {
> +			if (msl->part[p].boot_ind & 0x7f) {
>  				ret = 0;
>  				break;
>  			}
>  			/* Must have at least one non-empty partition */
> -			if (buf.part[p].nr_sects)
> +			if (msl->part[p].nr_sects)
> +				ret = 1;
> +		}
> +	} else if ((sgi = (sgi_disklabel *)buf) && xlate32(sgi->magic) == SGI_LABEL_MAGIC) {
> +		for (i = 0;i < SGI_MAX_PARTITIONS;i++) {
> +			if (xlate32(sgi->partitions[i].num_blocks)) {
>  				ret = 1;
> +				break;
> +			}
> +		}
> +	} else if ((sun = (sun_disklabel *)buf) && xlate16(sun->magic) == SUN_LABEL_MAGIC) {
> +		for (i = 0;i < SUN_MAX_PARTITIONS;i++) {
> +			if (sun->partitions[i].num_sectors) {
> +				ret = 1;
> +				break;
> +			}
>  		}
>  	}
>  
> -- 
> 1.8.4.5
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel

-- 
---
Liuhua Wang


