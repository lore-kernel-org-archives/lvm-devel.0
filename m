From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 15 May 2009 19:57:50 +0200
Subject: [PATCH] Add escape sequence for ':' in command's PV list
In-Reply-To: <1242390460.2506.8.camel@f10-node1>
References: <4A0AAA51.8040609@redhat.com>	<1242243809.2556.19.camel@f10-node1>
	<4A0BE56B.2000508@redhat.com>	<1242329131.3943.111.camel@f10-node1>	<1242389250.2506.6.camel@f10-node1>
	<1242390460.2506.8.camel@f10-node1>
Message-ID: <4A0DAD1E.4090805@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/15/2009 02:27 PM, Dave Wysochanski wrote:
>> Upon further thought, I agree with you Peter - let's reject the ":" in
>> pvcreate/vgcreate commands and print a message about pe range not
>> allowed in these commands.  This way the commands are all consistent -
>> require a "::" if any pvname contains a ":" in any of the commands.
>>
> 
> Updated man page patch is attached.
> 

OK, thanks. I'll move the code to a separate function then and I'll add checks
for pvcreate/vgcreate, too.

Peter


