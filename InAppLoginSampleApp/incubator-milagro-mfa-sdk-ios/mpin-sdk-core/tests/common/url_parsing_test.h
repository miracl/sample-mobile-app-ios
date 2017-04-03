/*
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
*/

/*
 * Url utility class test
 */

#ifndef _TEST_URL_PARSING_H_
#define _TEST_URL_PARSING_H_

#include "utils.h"
#include <vector>

class UrlTest
{
public:
    bool Parse();
    util::Url GetParsedUrl() const;

    std::string urlString;
    util::Url correctUrl;
};

typedef std::vector<UrlTest> UrlTestVector;

namespace std
{
    std::ostream& operator<<(std::ostream& out, const util::Url& url);
}

UrlTestVector& GetUrlTests();
void DoStandaloneUrlParsingTest();

#endif // _TEST_URL_PARSING_H_
