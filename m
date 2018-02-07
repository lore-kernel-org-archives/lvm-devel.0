From: Eric Ren <zren@suse.com>
Date: Wed, 7 Feb 2018 18:06:48 +0800
Subject: master - pvmove: reinstantiate clustered pvmove
In-Reply-To: <5cecc671-dbc2-c0d7-e1a9-64d4bcb68860@suse.com>
References: <201802012058.w11KwnMa018375@lists01.pubmisc.prod.ext.phx2.redhat.com>
	<5cecc671-dbc2-c0d7-e1a9-64d4bcb68860@suse.com>
Message-ID: <96698fd4-770c-2189-2bbe-5134c3405e50@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


> GDB it a little bit. The problem seems because:
>
> _pvmove_target_present(cmd, 1)
>
>
> will always return 0 - "not found".
>
> During one pvmove command, the _pvmove_target_present() is invoked 
> twice. At first call,
> "segtype->ops->target_present()", i.e _mirrored_target_present() will 
> set "_mirrored_checked = 0".

Ooops, s/"_mirrored_checked = 0"/"_mirrored_checked = 1"

Sorry.

Eric


