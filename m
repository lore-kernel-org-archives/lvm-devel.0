Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1D15263F5B
	for <lvm-devel@lists.linux.dev>; Thu,  7 Aug 2025 14:26:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754576785; cv=none; b=ua2pzxr4RLMt1yWyc6NtZCs9iPWICnouKJHK0kyy/yk81aEtiOylVz35zuqdUxgXs9iQ6KnIGRVwDaH7o29vHrk9UOfToTv89PVaRtG/RrbX7pH0DEFNoHDkzesYlVm+93mJO4ssHl+PDPphPvLNOmaAseRNjGMtVcUJdNDjpLo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754576785; c=relaxed/simple;
	bh=rYxTBAKF459iV1yKczsdNjkr2Yv6j2ABP4lfpFL72u4=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=J0nP0Sn51m6H/s/t6lCt+52USHRPRnqEMEa/9kXk4YMAwbtzDZQJ+9Xn1bsRoyBl8LaHemvztHN+tIKZ/1R89QC5PY4lEj+00DD1aVkuwda9jE0atWhyN29Z4p7LYDW2zzMwPAW88gGz59sqve6Ks1mwit2bl8pYCHU8TA2hiSM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=CgiQNjmY; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="CgiQNjmY"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1754576782;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=96iJhQZzc9yhAvF63R9GN2n/jrYZQf2lXMcI/gjbm9Q=;
	b=CgiQNjmYeAo0vwpPS/lSvnhzap4NiHN84g/Q6ADrg1yfe0909UsrSefls0fUz5OtB7XXPe
	sNnWEbQgk9kAfnM/xWT2CrggIRZC2/vD5L9ZycTUIOOqL5+rfiTnQo/XesUsswy2gM0DyG
	1Hvuqb5wbVKVQUBFBXu0Q+CLGlpkzO4=
Received: from mail-yw1-f200.google.com (mail-yw1-f200.google.com
 [209.85.128.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-689-0STemAP5MqiH4XzDEbn56A-1; Thu, 07 Aug 2025 10:26:21 -0400
X-MC-Unique: 0STemAP5MqiH4XzDEbn56A-1
X-Mimecast-MFC-AGG-ID: 0STemAP5MqiH4XzDEbn56A_1754576781
Received: by mail-yw1-f200.google.com with SMTP id 00721157ae682-707cf1b0ecbso16688157b3.2
        for <lvm-devel@lists.linux.dev>; Thu, 07 Aug 2025 07:26:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1754576781; x=1755181581;
        h=content-transfer-encoding:in-reply-to:organization:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=96iJhQZzc9yhAvF63R9GN2n/jrYZQf2lXMcI/gjbm9Q=;
        b=sXlx3njHWVqHPFaGysUDRNnqZav7xyWovPMEXC76HckxzdiSt0AJ68IzaI++liwUwX
         08jEOtYu/JZ3FbM20xKT+KR0rCn3qaPGzVkgwemdrq3U5WQWoRvGaqSrz2LuCAjiLJ2M
         ZldZv8qoa/WqTN58FSCwtHN/8TMye0ywx0jCob1oHytoUWUr91HTPJn0dJkcAChWsr0A
         zd1mQs4WFE64iQn1YZgMOLVOUeO6ZNS2gaAXPXmcDVsI1WnCmxl5YMMjk4GVyYQGowGP
         9zB2qxdcm37/wc7CzHTez8bYZStfQzhobpl5TSuutOR2wCvSEgwsR1UD8IemlPAMvso+
         k1yQ==
X-Forwarded-Encrypted: i=1; AJvYcCWj3FILlfwej0SmwkB8vKqTq+IOeQu9KBq9PKaCSbAICE9XECwNv+wz0oLZ42L8gYsegdfzXFCGF7M=@lists.linux.dev
X-Gm-Message-State: AOJu0YwSeZ8BDNLQz1Zu9hMgvX6H+29J+wuBI2NRE7JGg+fcTKW1asIa
	tWkogK0/aO/UdMTnWtcLCKiF6CRNGpH5iNe8tNBg1mRrIKxYJCIFnXfN9y6U2ka2XanYpKTJA9x
	E5/7gc/4M6zP+HUsBr5K7u8jtFpG4rAv1pyyHF13x/D4FNV0Sls5MJsSeSrZ4nw==
X-Gm-Gg: ASbGncuxc4AVJUpNcUCErseFTIzjijX7REBdxfZB6CM1R0KLKU510AJQIs5DGyMMk1U
	B2x9BqDm2RBnMDtenBaKewRw/XAmDsFE7HYqAzV5LNxMwboQsurnkuoayn2eY/sRj4B8ALa3b+r
	HgBnHouvegXsp48e4i21SXAUZjEombOQvqxRmXZhAyK4M1tvnbNmzpt0cKHPCgJkrH5cKnCpoMB
	fB75gvY4YLjuzL76YtHVxDtsLxYtSKIZshwB7KPTpOR06KSMgAhYy/AxXFsUGaK7+Be+ZEgNJBJ
	f/605hwWWEgJQgDTLg==
X-Received: by 2002:a05:690c:620f:b0:719:e1cf:ea8d with SMTP id 00721157ae682-71bc977a9damr81230577b3.11.1754576780787;
        Thu, 07 Aug 2025 07:26:20 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IGERbKGQIWQmitfkmsmGES56uxh3hKzAIMSSCir6DSVMZMTzjRDf6k+Kf351fz61j1Uz0NHCg==
X-Received: by 2002:a05:690c:620f:b0:719:e1cf:ea8d with SMTP id 00721157ae682-71bc977a9damr81230207b3.11.1754576780240;
        Thu, 07 Aug 2025 07:26:20 -0700 (PDT)
Received: from [192.168.8.164] ([46.188.135.63])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-71bd21323c8sm9456527b3.23.2025.08.07.07.26.11
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 07 Aug 2025 07:26:19 -0700 (PDT)
Message-ID: <8ca3f1aa-b3fc-4270-aa61-3f7cfdcaf157@redhat.com>
Date: Thu, 7 Aug 2025 16:26:04 +0200
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] fix random failures in shell/integrity.sh
To: Mikulas Patocka <mpatocka@redhat.com>,
 Stuart D Gathman <stuart@gathman.org>
Cc: John Stoffel <john@stoffel.org>, Peter Rajnoha <prajnoha@redhat.com>,
 Heinz Mauelshagen <heinzm@redhat.com>, David Teigland <teigland@redhat.com>,
 linux-lvm@lists.linux.dev, lvm-devel@lists.linux.dev
References: <06d25902-7239-1fc7-ec3b-1798332c3315@redhat.com>
 <26771.51188.491376.658337@quad.stoffel.home>
 <65919799-842c-9428-8bfc-5c1c0671338@gathman.org>
 <36d044e7-75f0-9b53-8969-0423fade7ea7@redhat.com>
From: Zdenek Kabelac <zkabelac@redhat.com>
Organization: RedHat
In-Reply-To: <36d044e7-75f0-9b53-8969-0423fade7ea7@redhat.com>
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: 17icuNxNMmHIV6RzVJasMzlQGeOjMl461rfJfXysTQQ_1754576781
X-Mimecast-Originator: redhat.com
Content-Language: en-US, cs
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dne 07. 08. 25 v 16:07 Mikulas Patocka napsal(a):
> 
> 
> On Thu, 7 Aug 2025, Stuart D Gathman wrote:
> 
>> On Wed, 6 Aug 2025, John Stoffel wrote:
>>
>>>>>>>> "Mikulas" == Mikulas Patocka <mpatocka@redhat.com> writes:
>>>
>>>> The problem is that the raid1 implementation may freely choose which leg
>>>> to read from. If it chooses to read from the non-corrupted leg, the
>>>> corruption is not detected, the number of mismatches is not incremented
>>>> and the test reports this as a failure.
>>>
>>> So wait, how is integrity supposed to work in this situation then?  In
>>> real life?  I understand the test is hard, maybe doing it in a loop
>>> three times?  Or configure the RAID1 to prefer one half over another
>>> is the way to make this test work?
> 
> If you want to make sure that you detect (and correct) all mismatches, you
> have to scrub the raid array.
> 
>> Linux needs an optional parameter to read() syscall that is "leg index"
>> for the blk interface.  Thus, btrfs scrub can check all legs, and this
>> test can check all legs.  Filesystems with checks can repair corruption
>> by rewriting the block after finding a leg with correct csum.
>>
>> This only needs a few bits (how many legs can there be?), so can go in
>> the FLAGS argument.
> 
> I think that adding a new bit for the read syscalls is not a workable
> solition. There are so many programs using the read() syscall and teaching
> them to use this new bit is impossible.

I believe the idea of the test is to physically check the proper leg is 
reporting an error.

So instead of this proposed patch - we should actually enforce reading leg 
with lvchange --writemostly to select the preferred leg among other legs.

The bigger question is though - that user doesn't have normally a single 
workable leg - as  'reading' is spread across all legs - thus when one leg 
goes away - it could have happen that other legs have also some 'errors' 
spread around...


Zdenek

