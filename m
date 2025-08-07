Received: from mail.stoffel.org (mail.stoffel.org [172.104.24.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8AF5222C339;
	Thu,  7 Aug 2025 14:38:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=172.104.24.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754577513; cv=none; b=b21LTPAXhhPjY8blMOWJcEHPEPrc5SdKqqB/9g2FwFdpJ6UFBfsMWINQ/AV2sVqqwZhDuV/SlejTx+es6MBwiJarjvsmJF+NCpWOKK+lYFM11UJwAbg1o5f5e90a5c+nUcqH+NuaX+0Lg2gfFoTQgG11EqwP7KoAd831KPgyj5s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754577513; c=relaxed/simple;
	bh=lCT5JlTOaNoyMvJnJBNDH29m9ASJl3kMwuzfgpkJy90=;
	h=MIME-Version:Content-Type:Message-ID:Date:From:To:Cc:Subject:
	 In-Reply-To:References; b=WVyRCSGZp0wYlO/0xOUM+0F8orwjzx58IbO0MB6f18ETxVV3zkNds05Y05E4wNfyO4D+4VMcED/gTyWDAg/8vOX/0Z3fYumMJqT7rlIp33jhZ2P0A3QthdYDyfQY/65A8+mp2LRlp68emAR5ortReCy/cyyhSJq7kE26GLRvsAE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stoffel.org; spf=pass smtp.mailfrom=stoffel.org; dkim=pass (2048-bit key) header.d=stoffel.org header.i=@stoffel.org header.b=WGC6XJkC; arc=none smtp.client-ip=172.104.24.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stoffel.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=stoffel.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=stoffel.org header.i=@stoffel.org header.b="WGC6XJkC"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=stoffel.org;
 i=@stoffel.org; q=dns/txt; s=20250308; t=1754577509; h=mime-version :
 content-type : content-transfer-encoding : message-id : date : from :
 to : cc : subject : in-reply-to : references : from;
 bh=lCT5JlTOaNoyMvJnJBNDH29m9ASJl3kMwuzfgpkJy90=;
 b=WGC6XJkCgV5LK9a/OFYdZq25q98TUpmkwd5StP7gZPsMuLw+Lgw1Ubyjq3UoP0iBlL0wO
 vCEgS0ye9wVBOkHm5q+JtPikL6xho3KbdOKlydAeQhae1wq11JBV9Zx0H/GarhT1Qp+mHfc
 LTyV8lS+X561g8mlxSl5tA9NlPn6X1PpxrDbcRO2ZZor6/na/fjmsfS1bDQYtVMdVJClFFM
 4oNcEJbYvZ3I5u1lde6chh606In4H+6HOvIja9t9xGahWwVHpN25cuIQOLYJLv4igE2BK+a
 D/n2/6JPPlqq8q8elIzfX1NMohGXwkYbSpfnheAZsP1KJJPQNtwCDzZ5x0zA==
Received: from quad.stoffel.org (syn-097-095-183-072.res.spectrum.com [97.95.183.72])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.stoffel.org (Postfix) with ESMTPSA id DA8801E69A;
	Thu,  7 Aug 2025 10:38:29 -0400 (EDT)
Received: by quad.stoffel.org (Postfix, from userid 1000)
	id 468BAA11A9; Thu,  7 Aug 2025 10:38:29 -0400 (EDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <26772.47717.267782.824503@quad.stoffel.home>
Date: Thu, 7 Aug 2025 10:38:29 -0400
From: "John Stoffel" <john@stoffel.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Stuart D Gathman <stuart@gathman.org>,
    John Stoffel <john@stoffel.org>,
    Peter Rajnoha <prajnoha@redhat.com>,
    Zdenek Kabelac <zkabelac@redhat.com>,
    Heinz Mauelshagen <heinzm@redhat.com>,
    David Teigland <teigland@redhat.com>,
    linux-lvm@lists.linux.dev,
    lvm-devel@lists.linux.dev
X-Clacks-Overhead: GNU Terry Pratchett
Subject: Re: [PATCH] fix random failures in shell/integrity.sh
In-Reply-To: <36d044e7-75f0-9b53-8969-0423fade7ea7@redhat.com>
References: <06d25902-7239-1fc7-ec3b-1798332c3315@redhat.com>
	<26771.51188.491376.658337@quad.stoffel.home>
	<65919799-842c-9428-8bfc-5c1c0671338@gathman.org>
	<36d044e7-75f0-9b53-8969-0423fade7ea7@redhat.com>
X-Mailer: VM 8.3.x under 28.2 (x86_64-pc-linux-gnu)

>>>>> "Mikulas" == Mikulas Patocka <mpatocka@redhat.com> writes:

> On Thu, 7 Aug 2025, Stuart D Gathman wrote:

>> On Wed, 6 Aug 2025, John Stoffel wrote:
>> 
>> > > > > > > "Mikulas" == Mikulas Patocka <mpatocka@redhat.com> writes:
>> > 
>> > > The problem is that the raid1 implementation may freely choose which leg
>> > > to read from. If it chooses to read from the non-corrupted leg, the
>> > > corruption is not detected, the number of mismatches is not incremented
>> > > and the test reports this as a failure.
>> > 
>> > So wait, how is integrity supposed to work in this situation then?  In
>> > real life?  I understand the test is hard, maybe doing it in a loop
>> > three times?  Or configure the RAID1 to prefer one half over another
>> > is the way to make this test work?

> If you want to make sure that you detect (and correct) all mismatches, you 
> have to scrub the raid array.

And how do you know which level of the array is showing the errors?  I
could have a RAID1 array composed of a single partition on the left
side, but then a RAID0 of two smaller disks on the right side.  So how
would this read() flag know what to do?  

I would assume the integrity sub-system would be reading from both
sides and comparing them to look for errors.  When you find a
mis-match, how do you tell which side is wrong?  

>> Linux needs an optional parameter to read() syscall that is "leg index"
>> for the blk interface.  Thus, btrfs scrub can check all legs, and this
>> test can check all legs.  Filesystems with checks can repair corruption
>> by rewriting the block after finding a leg with correct csum.
>> 
>> This only needs a few bits (how many legs can there be?), so can go in
>> the FLAGS argument.

> I think that adding a new bit for the read syscalls is not a
> workable solition. There are so many programs using the read()
> syscall and teaching them to use this new bit is impossible.

It's also the completely wrong level for this type of support.  But
maybe they can convince us with a pseudo-code example of how an
application would use this read() extension to solve the issue?  

But right now, it's just for testing, and if the tests don't work
correctly without a silly workaround like this, then your tests aren't
representative of the real world use!  

John


