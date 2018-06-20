/*
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.trafficcontrol.exception;

public class InvalidJsonException extends TrafficControlException {
	private static final long serialVersionUID = 1884362711438565843L;

	public InvalidJsonException() {
		super();
	}

	public InvalidJsonException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
	}

	public InvalidJsonException(String message, Throwable cause) {
		super(message, cause);
	}

	public InvalidJsonException(String message) {
		super(message);
	}

	public InvalidJsonException(Throwable cause) {
		super(cause);
	}
	
}