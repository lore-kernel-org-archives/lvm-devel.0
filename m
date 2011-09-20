From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 20 Sep 2011 15:10:10 +0200
Subject: [PATCH 4/7][retry remove] Add new "dm_device_has_holders" fn to libdm
In-Reply-To: <4E788DA5.8010304@redhat.com>
References: <4E788DA5.8010304@redhat.com>
Message-ID: <4E7890B2.9060409@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.9.2011 14:57, Peter Rajnoha napsal(a):
> This is a helper function used both in libdevmapper and in LVM
> to test whether there are any devices that make use of certain
> device given as parameter (this will partially replace "open_count"
> check, see the following patch...).
> 
> Peter
> ---
>  libdm/libdevmapper.h |    6 ++++++
>  libdm/libdm-common.c |   36 ++++++++++++++++++++++++++++++++++++
>  2 files changed, 42 insertions(+), 0 deletions(-)
> 
> diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
> index ae39262..9df34bb 100644
> --- a/libdm/libdevmapper.h
> +++ b/libdm/libdevmapper.h
> @@ -267,6 +267,12 @@ const char *dm_sysfs_dir(void);
>  int dm_is_dm_major(uint32_t major);
>  
>  /*
> + * Determine whether a device has holders.
> + * (this requires sysfs directory to be configured via dm_set_sysfs_dir)
> + */
> +int dm_device_has_holders(uint32_t major, uint32_t minor);
> +
> +/*
>   * Release library resources
>   */
>  void dm_lib_release(void);
> diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
> index 7517fb1..7ea78af 100644
> --- a/libdm/libdm-common.c
> +++ b/libdm/libdm-common.c
> @@ -1051,6 +1051,42 @@ const char *dm_sysfs_dir(void)
>  	return _sysfs_dir;
>  }
>  
> +static int _is_empty_dir(const char *dir)
> +{
> +	struct dirent *dirent;
> +	DIR *d;
> +
> +	if (!(d = opendir(dir))) {
> +		log_sys_error("opendir", dir);
> +		return 0;
> +	}
> +
> +	while ((dirent = readdir(d)))
> +		if (strcmp(dirent->d_name, ".") && strcmp(dirent->d_name, ".."))
> +			break;

Hmm since  readdir() may return -1 - this looks like error check is missing
here. And since it's copy from  lvm-file.c  - maybe generic  dm_is_empty_dir
with all log_error code inside might be useful.

Zdenek


