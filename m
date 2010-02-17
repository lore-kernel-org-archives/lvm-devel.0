From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Feb 2010 09:42:10 +0100
Subject: [PATCH 7/7] Update lvm2app interactive unit test for vg/lv tags.
In-Reply-To: <1266349189-23166-8-git-send-email-dwysocha@redhat.com>
References: <1266349189-23166-1-git-send-email-dwysocha@redhat.com>	<1266349189-23166-2-git-send-email-dwysocha@redhat.com>	<1266349189-23166-3-git-send-email-dwysocha@redhat.com>	<1266349189-23166-4-git-send-email-dwysocha@redhat.com>	<1266349189-23166-5-git-send-email-dwysocha@redhat.com>	<1266349189-23166-6-git-send-email-dwysocha@redhat.com>	<1266349189-23166-7-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-8-git-send-email-dwysocha@redhat.com>
Message-ID: <4B7BABE2.3000300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 16.2.2010 20:39, Dave Wysochanski wrote:
> Simple test of vg/lv tag addition/deletion.
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
>  
>  	list = lvm_list_vg_uuids(libh);
>  	printf("VG uuids:\n");
>  	dm_list_iterate_items(strl, list) {
> -		tmp = strl->str;
> -		printf("%s\n", tmp);
> +		printf("%s\n", strl->str);


Simplier:  puts(strl->str);

adds trailing '\n' automaticaly.

Zdenek


