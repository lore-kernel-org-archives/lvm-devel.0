From: Hellmut GreenUnit <hellmut@greenunit.de>
Date: Wed, 1 Feb 2017 22:10:10 +0100
Subject: Fwd: Fwd: Re: lvm git "pre-release" "post-release" question
In-Reply-To: <48a5841d-2e20-3141-2255-2ad02f0889e8@mglug.de>
References: <48a5841d-2e20-3141-2255-2ad02f0889e8@mglug.de>
Message-ID: <293f8212-0b0c-77d4-eb9b-30cd7078f157@greenunit.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair,
I got your message from my colleague Oliver-.

I would like to realize a similar functionality for our git-repo.

I found the wrapper script 'git-release', which seems to do exactly what
you describe but unfortunately I don't remember (and didn't save)  the
site-address where I took it from.

What I'm interested in are the two scripts whcih are called usewd the
Bash-function hook: 'pre-release' and 'post-release'.

Would you mind to send me your versions of these scripts?
So I don't have to re-invent the wheel ;-)

Many thanks in advance and best regards


Dr. Hellmut Weber


-------- Forwarded Message --------
Subject: Fwd: Re: [lvm-devel] lvm git "pre-release" "post-release" question
Date: Wed, 1 Feb 2017 13:27:02 +0100
From: Oliver Rath <rath@mglug.de>
To: Hellmut GreenUnit <hellmut@greenunit.de>

Gru?
Oliver


-------- Forwarded Message --------
Subject: Re: [lvm-devel] lvm git "pre-release" "post-release" question
Date: Wed, 1 Feb 2017 11:14:28 +0000
From: Alasdair G Kergon <agk@redhat.com>
Reply-To: LVM2 development <lvm-devel@redhat.com>
Organization: Red Hat UK Ltd. Registered in England and Wales, number
03798903. Registered Office: Peninsular House, 30-36 Monument Street,
4th Floor, London, England, EC3R 8NB.
To: LVM2 development <lvm-devel@redhat.com>

On Wed, Feb 01, 2017 at 11:38:14AM +0100, Oliver Rath wrote:
> every time you offer a new version number, in git I see these
> "pre-release" "post-release" commits. What is it good for? Is this a
> git-functionality or what kind of tool you are using for this?
 Those commits simply update the version number/date and tidy the changelog
before/after generating a tarball.

Alasdair

--
lvm-devel mailing list
lvm-devel at redhat.com
https://www.redhat.com/mailman/listinfo/lvm-devel


-- 
GreenUnit.UG
Agnes-Pockels-Bogen 1
D - 80992 M?nchen
Tel.: +49 89 8905729-10
Fax:  +49 89 8905729-29
mailto:h.weber at greenunit.de

Gesch?ftsf?hrer: Dipl.-Ing. G?nter Rath
Amtsgericht M?nchen, HRB 187881
Internet: www.greenunit.de


