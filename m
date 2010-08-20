From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 20 Aug 2010 15:03:29 +0200
Subject: patch2/4: lvm manpages
In-Reply-To: <1282262321.3337.95.camel@fermat.scientia.net>
References: <1282262321.3337.95.camel@fermat.scientia.net>
Message-ID: <4C6E7D21.2050709@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.8.2010 01:58, Christoph Anton Mitterer napsal(a):
> 2) lvm.8.non-implemented-commands.patch
> Aligned the "style" how in the two sections (built-in commands and
> commands)
> unimplemented commands are documented. Just cosmetic of course.
> I guess the current style of the commands section is better, built-in
> commands list the unimplemented one just as the implemented commands.
> Also removed pvdata from the list of unimplemented commands, as this
> seems
> to be an unimplemented built-in command.
> 
> 
> 
> 
> --- lvm.8	2010-06-23 16:25:44.099108000 +0200
> +++ lvm.8	2010-06-23 16:34:46.931357952 +0200
> @@ -48,11 +48,11 @@
>  .TP
>  \fBhelp\fP \(em Display the help text.
>  .TP
> -\fBpvdata\fP \(em Not implemented in LVM2.
> -.TP
>  \fBsegtypes\fP \(em Display recognised logical volume segment types.
>  .TP

This one is probably ok.

>  \fBversion\fP \(em Display version information.
> +.TP
> +The following built-in commands are not implemented in LVM2: pvdata
>  .LP

But I think it makes no sense to create two 'not implemented' lines in
manpage. So I would leave it together with lvmsar & lvmsadc.


Zdenek


