From: Petr Rockai <prockai@redhat.com>
Date: Fri, 20 Mar 2009 20:39:46 +0100
Subject: [PATCH] fix vgcfgrestore segfault if PV is missing
In-Reply-To: <49C3D606.8000101@redhat.com> (Milan Broz's message of "Fri, 20
	Mar 2009 18:44:38 +0100")
References: <49C3D606.8000101@redhat.com>
Message-ID: <87ljr0htkt.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Caused by introducing MISSING_PV flag, previously vg_read failed here.
With my recent patches, vg_read fails here again for tools that don't set
handles_missing_pvs (this fixes more segfaults of this kind, although
ultimately, this is not the right fix, merely a workaround... making the code
aware of MISSING_PV sounds like a better approach overall).

> diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
> index 0406ae5..4da267e 100644
> --- a/lib/format_text/archiver.c
> +++ b/lib/format_text/archiver.c
> @@ -333,6 +333,12 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
>  	if (!(vg = backup_read_vg(cmd, vg_name, file)))
>  		return_0;
>  
> +	/*
> +	 * If PV is missing, there is already message from read above
> +	 */
> +	if (vg_missing_pv_count(vg))
> +		return 0;
> +
>  	return backup_restore_vg(cmd, vg);
>  }
>  
> diff --git a/test/t-covercmd.sh b/test/t-covercmd.sh
> index 445c7d9..ed191bc 100755
> --- a/test/t-covercmd.sh
> +++ b/test/t-covercmd.sh
> @@ -14,6 +14,8 @@
>  
>  . ./test-utils.sh
>  
> +TEST_UUID="aaaaaa-aaaa-aaaa-aaaa-aaaa-aaaa-aaaaaa"
> +
>  get_lvs_()
>  {
>    case $(lvs --units s --nosuffix --noheadings -o $1_read_ahead "$vg"/"$lv") in
> @@ -28,7 +30,7 @@ pvcreate $dev1
>  pvcreate --metadatacopies 0 $dev2
>  pvcreate --metadatacopies 0 $dev3
>  pvcreate $dev4
> -pvcreate --metadatacopies 0 $dev5
> +pvcreate -u $TEST_UUID --metadatacopies 0 $dev5
>  vgcreate -c n $vg $devs
>  lvcreate -n $lv -l 5 -i5 -I256 $vg
>  
> @@ -67,6 +69,9 @@ lvrename "$vg" "$lv" "$lv-rename"
>  vgcfgbackup -f "$(pwd)/backup.$$" "$vg"
>  vgchange -an "$vg"
>  vgcfgrestore  -f "$(pwd)/backup.$$" "$vg"
> +pvremove -y -ff $dev5
> +not vgcfgrestore  -f "$(pwd)/backup.$$" "$vg"
> +pvcreate -u $TEST_UUID --restorefile  "$(pwd)/backup.$$" $dev5
>  vgremove -f "$vg"
>  pvresize --setphysicalvolumesize 10M "$dev1"
The patch does what the advert says. It also comes with a test
update. Therefore,

Acked-By: Petr Rockai <prockai@redhat.com>

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


