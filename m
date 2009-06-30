From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 30 Jun 2009 19:44:35 +0100
Subject: Re: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
In-Reply-To: <20090630183934.11350.qmail@sourceware.org>
References: <20090630183934.11350.qmail@sourceware.org>
Message-ID: <20090630184435.GH20848@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jun 30, 2009 at 06:39:34PM -0000, agk at sourceware.org wrote:
> Log message:
> 	pre-release tidy up
 
lvconvert still needs further cleaning up: there remain inconsistencies
between the available options, man page, help text and error messages.
(E.g. --repair missing from synopsis)

Alasdair


