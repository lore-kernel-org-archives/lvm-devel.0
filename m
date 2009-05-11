From: Petr Rockai <prockai@redhat.com>
Date: Mon, 11 May 2009 08:15:35 +0200
Subject: [PATCH 7/7] Remove import paramater from lv_create_empty.
In-Reply-To: <a46a601acc54a18f46dc8a0fd483497cec77d046.1241620083.git.mbroz@redhat.com>
	(Milan Broz's message of "Wed, 6 May 2009 16:43:04 +0200")
References: <cover.1241620083.git.mbroz@redhat.com>
	<cover.1241620083.git.mbroz@redhat.com>
	<a46a601acc54a18f46dc8a0fd483497cec77d046.1241620083.git.mbroz@redhat.com>
Message-ID: <87vdo8rwqg.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Now the max_lv check is performed in vg_add_lv and import parameter in
> lv_create_empty has no use.
Indeed -- and good riddance, too.

> Patch also adds simple max_lv tests into testsuite
Good.

> Signed-off-by: Milan Broz <mbroz@redhat.com>
Acked-By: Petr Rockai <prockai@redhat.com>

> -	if (!import)
> +	if (status & VISIBLE_LV)
>  		log_verbose("Creating logical volume %s", name);
Would it make sense to use lv_is_visible there? It's just a verbose log
message, so I guess it wouldn't matter much?

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


