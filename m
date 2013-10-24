From: Brassow Jonathan <jbrassow@redhat.com>
Date: Thu, 24 Oct 2013 10:48:23 -0500
Subject: Fwd: [linux-lvm] LVM2.2.02.103/tools/lvchange.c:779: bad if test ?
In-Reply-To: <526909C4.3080504@redhat.com>
References: <DUB118-W973F5E6250AE338D1B00D9C030@phx.gbl>
	<526909C4.3080504@redhat.com>
Message-ID: <B9375F18-5422-44A3-A271-C0CC92FB6E75@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

yup.  We could just get rid of the checks for t, y, and n.  The important one is the check for ':'.

Basically, we are asking if the user has supplied a mode (i.e. ':{n|y|t}).  If not, then the meaning is the same as ':y' which we then append.

Later code checks if the last character is a proper y, n, or t; and errors if it is not.

The reason this logic hasn't caused any problems is because we only care about the ':' anyway - the rest is useless.

 brassow

On Oct 24, 2013, at 6:51 AM, Marian Csontos wrote:

> And the && is wrong as well.
> So || instead of && and inside braces &&s instead of ||s.
> 
> Now it matches anything /[^:].$/ but I believe it was intended to be /[^:].$|:[tyn]$/ which is wrong too but in fact should be /[^:].$/ so it is in fact weirdly written correct implementation. =8-O
> 
> I wonder, is it possible to have the PV matching /:[^tyn]$/?
> In such case it is, then /:[tyn]$/ should be valid as well, shold not it?
> 
> I suggest:
> 
> if /[^:]./:
>    - add default
> else if /:[^tyn]$/
>    - should be internal error
>    - recovery: last character should be _replaced_ by default
> else # /:[tyn]/
>    - NOP
> 
> -- Martian
> 
> -------- Original Message --------
> Subject: [linux-lvm] LVM2.2.02.103/tools/lvchange.c:779: bad if test ?
> Date: Wed, 23 Oct 2013 20:26:04 +0000
> From: David Binderman <dcb314@hotmail.com>
> Reply-To: LVM general discussion and development <linux-lvm@redhat.com>
> To: linux-lvm at redhat.com <linux-lvm@redhat.com>
> 
> Hello there,
> 
> I just compiled LVM2.2.02.103 with the extra Linux gcc compiler
> flag -Wlogical-op
> 
> It said
> 
> lvchange.c:779:10: warning: logical 'or' of collectively exhaustive tests is always true [-Wlogical-op]
> 
> Source code is
> 
>                 ((tmp_str[tmp_str_len - 1] != 't') ||
>                  (tmp_str[tmp_str_len - 1] != 'y') ||
>                  (tmp_str[tmp_str_len - 1] != 'n'))))
> 
> Suggest swap || for &&
> 
> Regards
> 
> David Binderman 		 	   		
> 
> _______________________________________________
> linux-lvm mailing list
> linux-lvm at redhat.com
> https://www.redhat.com/mailman/listinfo/linux-lvm
> read the LVM HOW-TO at http://tldp.org/HOWTO/LVM-HOWTO/
> 
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel



