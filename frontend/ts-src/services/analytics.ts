import {Logger} from "./logger";
import splitbee from '@splitbee/web';
import {Data} from "../types/ports";
import {SplitbeeConf} from "../conf";

export interface Analytics {
    trackPage: (name: string) => void
    trackEvent: (name: string, details?: Data) => void
    trackError: (name: string, details?: Data) => void
}

export class SplitbeeAnalytics implements Analytics {
    constructor(conf: SplitbeeConf) {
        splitbee.init(conf)
    }

    trackPage = (name: string): void => { /* automatically tracked, do nothing */
    }
    trackEvent = (name: string, details?: Data): void => {
        splitbee.track(name, details)
    }
    trackError = (name: string, details?: Data): void => { /* don't track errors in splitbee */
    }
}

export class LogAnalytics implements Analytics {
    constructor(private logger: Logger) {
    }

    trackPage = (name: string): void => this.logger.debug('analytics.page', name)
    trackEvent = (name: string, details?: Data): void => this.logger.debug('analytics.event', name, details)
    trackError = (name: string, details?: Data): void => this.logger.debug('analytics.error', name, details)
}
