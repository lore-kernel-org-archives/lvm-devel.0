From: Christoph Anton Mitterer <calestyo@scientia.net>
Date: Fri, 20 Aug 2010 13:12:06 +0000
Subject: patch2/4: lvm manpages
In-Reply-To: <4C6E7D21.2050709@redhat.com>
References: <1282262321.3337.95.camel@fermat.scientia.net>
	<4C6E7D21.2050709@redhat.com>
Message-ID: <94eac2a30feda6d4e7eb4f042c6a23ad@imap.dd24.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 20 Aug 2010 15:03:29 +0200, Zdenek Kabelac <zkabelac@redhat.com>
wrote:

>> -\fBpvdata\fP \(em Not implemented in LVM2.
> This one is probably ok.
If it's never going to be implemented, than probably yes =)
What about the others? Are they still planned to be written some day?


>>  \fBversion\fP \(em Display version information.
>> +.TP
>> +The following built-in commands are not implemented in LVM2: pvdata
>>  .LP
> 
> But I think it makes no sense to create two 'not implemented' lines in
> manpage. So I would leave it together with lvmsar & lvmsadc.
Just did this, because I didn't know pvdata was about to be dropped
completely,... and it was listed as built-in command (in contrast to the
"normal" commands). So I didn't want to move it down to the other
non-implemented line, thereby loosing this information.

But then it's ok I guess =)


Cheers,
Chris.


