Received: from mail-ed1-f49.google.com (mail-ed1-f49.google.com [209.85.208.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 12FC128850B
	for <lvm-devel@lists.linux.dev>; Sat, 25 Oct 2025 05:26:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1761370009; cv=none; b=a0wNP7Sr19+g+u8WTBZeDZx3VHdnRGwUsj0ezncyXRk9iK2acvbhLMId4BTd1HExju+7A6wdkU33W2BJq/WSiGbSGcLZOZYFwi0DAvJ8tHhBqAyu7TDXf7BAZrzGSoWQiQjxYMGME77nWJaTkkSuGYaOiMM5lT7flxMWR/QFFWQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1761370009; c=relaxed/simple;
	bh=/zQwfhMEJhTOa5/FV1euV1Dku1nFTDlTsbnBQjlqjDQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=khaVTYT4iyc5JProfXTnIpESp2jYPcfRMvrSglpATbG//Rezbu5DsqYth6y4UrINid4NJzDqrnN2o1p9LSwEQ4rJQQY1wvL+kxCqW42loMASyv668zLZRMPDr7tFLQ0+r9EE2UokQmdWcIh71EodlPIvDVdlG7syWso9JOPmZNc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=JP9LRKrF; arc=none smtp.client-ip=209.85.208.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JP9LRKrF"
Received: by mail-ed1-f49.google.com with SMTP id 4fb4d7f45d1cf-63c2d72581fso4244628a12.0
        for <lvm-devel@lists.linux.dev>; Fri, 24 Oct 2025 22:26:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1761370005; x=1761974805; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=mV8buuSZQP0rHOq5S4b8K+cOmbjRvDVQwA71gPDHBAE=;
        b=JP9LRKrFUu+tsGy0esuaoYE2yDegJdOOwqNi1CDdQQ+sC3zBYEe+PUXzP3Vq7o9lX4
         L/8wQ5+hbiYrm/UdbSQKOu8NHvjAcZbBEs3JqR5YABN/yLjgacjxFaAnowTrabzgY3IX
         0jd2o0va91UKiExAE36Ffl/9UDuJfCbF7LxubR9tR9eKsuCGByLTk45U9VGQ/o0BjLE2
         y0K9BYqkt20w1inCU/raYVo+66zIjlhX8lP/lJt+pN6X6uRxA5orgk3ROhh4oQSUZfyJ
         WjsoxCxlKUMwAjD1uxv95K4/L8VW5OLM0peMgETqXOFgGqzj/AVAgth6Pz7Vy4RK5w4b
         PX2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1761370005; x=1761974805;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=mV8buuSZQP0rHOq5S4b8K+cOmbjRvDVQwA71gPDHBAE=;
        b=ohMJ0qe+nIpaq9Gq5K77wfCIusEeg1O+fcRsGqU2P3rA4HO4p7nEFeE+BM9F7kmrkV
         LFKEVpI9GEB2NhR8KI9EKrrn926WmE42H3f4PIj/7tV3ar7lHgKfb3vbOqtMut3gJMka
         KhDBVQal3bFAlAhhP0BdkFlYPWu9lK9iQF/KJS8s4hDyrcy7fzBEkERb+/Naz297fK01
         J9NUKoKgX16kyZFThMkGofIaulbxcUSD4ol/T4gFFbWJZ9Gr4zNHL9HOMbsmaYy8bL6E
         +leFbTHi6jLwqOQbv0C/+iojUfhAazuwURfjXPEJsdOUvJlXa+I5smfIp+NcCHdZVdTl
         p7AA==
X-Forwarded-Encrypted: i=1; AJvYcCUQQZhuwv9q0NEq0xhy4fZvC1FJWROyF17RkaXfxuGac+Ar64UafopSjtwmzpQonouL41VW7xMpCI8=@lists.linux.dev
X-Gm-Message-State: AOJu0Ywsgo0e4H+OItEiKPUGAevn+VcU5PDS1iNxnnsrVXOxDGSAjhgG
	qu/36UVvCYz+V34TqAzgZM47TqctPyMghFoSackET1al+Vogb6xyYp50
X-Gm-Gg: ASbGncuQOj1ENyOjHQ/vKyCVdQFAORxJt7dAipHxQTha3uTu8p58rBihJOWUz0cizCX
	/UR+TZIGUDtcdMm6mmXJFQQTKWtpZiWI+nAuefwPTLO1VTfUNoOi0ikvOCiIakD6uOwLKCc1uJY
	VeGZ6NM1aptTSP9IyHTsPp2vzJo8wzuCe9Jw34Zdj6b//LeeG8iVOL9Ri2coJbmgAVcdTrZXGA/
	nT21TOpy8vR3V3y/rROnaaxoO62+ZRpTN6ktNQ/NBXa4wMHSGYEfjAsOzDahAUcW8BDj7k992cB
	omkrjc4Pw5/Atiqjs2SkaTGOodBt34oZIdR1SLSeafTt2hfxQOTs0P+GeLlwRH3VM+FHPqOFWDN
	Qjqg9quV+Oi2iSfYIdVAPRMtbG7DMYmn22/HX5egaEWiGQl4Gue4FJLUZrdKvEsZJIQ4vAxDlv0
	hF6fYasUXFN58=
X-Google-Smtp-Source: AGHT+IHk4JGeekekahtUg2k/EhAC9kyrxVTGjCsIExfHrDtgIcN62P8FCtHZWZXypDamfyJkpyvf/Q==
X-Received: by 2002:a05:6402:40d5:b0:628:5b8c:64b7 with SMTP id 4fb4d7f45d1cf-63c1f64ec00mr33191598a12.6.1761370005212;
        Fri, 24 Oct 2025 22:26:45 -0700 (PDT)
Received: from localhost ([212.73.77.104])
        by smtp.gmail.com with UTF8SMTPSA id 4fb4d7f45d1cf-63e7ef96105sm880960a12.19.2025.10.24.22.26.42
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 24 Oct 2025 22:26:44 -0700 (PDT)
From: Askar Safin <safinaskar@gmail.com>
To: safinaskar@gmail.com
Cc: Dell.Client.Kernel@dell.com,
	brauner@kernel.org,
	dm-devel@lists.linux.dev,
	ebiggers@kernel.org,
	gmazyland@gmail.com,
	kix@kix.es,
	linux-block@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-lvm@lists.linux.dev,
	linux-mm@kvack.org,
	linux-pm@vger.kernel.org,
	linux-raid@vger.kernel.org,
	lvm-devel@lists.linux.dev,
	mzxreary@0pointer.de,
	nphamcs@gmail.com,
	pavel@ucw.cz,
	rafael@kernel.org,
	ryncsn@gmail.com,
	torvalds@linux-foundation.org
Subject: Re: dm bug: hibernate to swap located on dm-integrity doesn't work (how to get data redundancy for swap?)
Date: Sat, 25 Oct 2025 08:26:37 +0300
Message-ID: <20251025052637.422902-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20251024163142.376903-1-safinaskar@gmail.com>
References: <20251024163142.376903-1-safinaskar@gmail.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Askar Safin <safinaskar@gmail.com>:
> Here is output of this script on master:
> https://zerobin.net/?68ef6601ab203a11#7zBZ44AaVKmvRq161MJaOXIXY/5Hiv+hRUxWoqyZ7uE=
[...]
> Also, you will find backtrace in logs above. Disregard it. I think this
> is just some master bug, which is unrelated to our dm-integrity bug.

That WARNING in logs is unrelated bug, which happens always when I hibernate.
I reported it here: https://lore.kernel.org/regressions/20251025050812.421905-1-safinaskar@gmail.com/

-- 
Askar Safin
