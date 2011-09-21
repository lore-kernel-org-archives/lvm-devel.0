From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 21 Sep 2011 10:39:10 +0200
Subject: [PATCH 8/7][retry remove] Also add check for filesystem use on a DM/LVM device - "dm_device_has_fs"
In-Reply-To: <4E78E64C.8080006@redhat.com>
References: <4E78E64C.8080006@redhat.com>
Message-ID: <4E79A2AE.5040708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/20/2011 09:15 PM +0100, Peter Rajnoha wrote:
> diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
> index 7ea78af..37b6902 100644
> --- a/libdm/libdm-common.c
> +++ b/libdm/libdm-common.c

> +int dm_device_has_fs(uint32_t major, uint32_t minor)
> +{
> +	char sysfs_path[PATH_MAX];
> +	char temp_path[PATH_MAX];
> +	size_t size;

I've just noticed - this must be int size!!!

> +	char *kernel_dev_name;
> +
> +	/* Get kernel device name first */
> +	if (dm_snprintf(sysfs_path, PATH_MAX, "%sdev/block/%" PRIu32 ":%" PRIu32,
> +			_sysfs_dir, major, minor) < 0) {
> +		log_error("sysfs_path dm_snprintf failed");
> +		return 0;
> +	}
> +
> +	if ((size = readlink(sysfs_path, temp_path, PATH_MAX)) < 0) {

...because of this check.

Peter


