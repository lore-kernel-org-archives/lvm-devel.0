From: Petr Rockai <prockai@redhat.com>
Date: Mon, 11 May 2009 08:27:13 +0200
Subject: [PATCH 1/7] Fix snapshot segment import to not use duplicate segments & replace.
In-Reply-To: <c09189aa621b29aa02b3c5b98fc65b900529b301.1241620083.git.mbroz@redhat.com>
	(Milan Broz's message of "Wed, 6 May 2009 16:42:58 +0200")
References: <cover.1241620083.git.mbroz@redhat.com>
	<cover.1241620083.git.mbroz@redhat.com>
	<c09189aa621b29aa02b3c5b98fc65b900529b301.1241620083.git.mbroz@redhat.com>
Message-ID: <87r5ywrw72.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Simplify the code, snapshot segment is properly initialized
> in text_import function now and do not need to be replaced
> by vg_add_snapshot call.
Looks OK, although it does duplicate part of the code. Nevertheless, seems like
a better compromise than the previous one. Also, the ugly part of the code
where lv_count is fiddled manually is fixed by a later patch.

> The vg_add_snapshot() is now usefull only for adding new snapshot. The name
> is always gewerated, remove it from function call.
Ack.

> Signed-off-by: Milan Broz <mbroz@redhat.com>
Acked-By: Petr Rockai <prockai@redhat.com>

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


