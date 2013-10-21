From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Mon, 21 Oct 2013 11:23:33 +0200
Subject: [PATCH] Fix return value of persistent_filters_dump if rename failed
In-Reply-To: <1197179055.5014720.1382034114736.JavaMail.root@redhat.com>
References: <654944611.5014340.1382034030200.JavaMail.root@redhat.com>
	<1197179055.5014720.1382034114736.JavaMail.root@redhat.com>
Message-ID: <5264F295.6040303@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 17.10.2013 20:21, Nir Soffer napsal(a):
> Hi all,
>
> Please review attached patch.
>
> Regards,
> Nir
>


Thanks for the patch - though the final solution will be a bit different.
Since from some time log_error should be used only for real-error - while
this error is only warning and it's result value is ignored.
It's only used for backtracing. So this patch doesn't change the final
result of executed command.


Zdenek




