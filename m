From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 22 Sep 2015 11:21:06 +0200
Subject: [PATCH] dmeventd: Fix segfault in _timeout_thread
In-Reply-To: <560014E0.4040200@redhat.com>
References: <560014E0.4040200@redhat.com>
Message-ID: <56011D82.7080201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/21/2015 04:32 PM, Marian Csontos wrote:
> In case thread was found, or thread registration failed after
> _register_for_timeout, thread_status was kept in timeout_list after
> deallocation.
>
> This should address BZ 1210514 and BZ 1220856.
>
> -- Martian
>
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>

NACK.

Kabi asked me to break this down into:
- actual fix
- refactoring

Also there is a copy'n'paste mistake there (thread_new used instead of 
thread in the added register_timeout.)

/me needs to learn git send-mail.


