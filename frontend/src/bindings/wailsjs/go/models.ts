export namespace models {
	
	export class Config {
	    theme: string;
	    font: string;
	    font_size: number;
	    line_wrap: boolean;
	    line_numbers: boolean;
	
	    static createFrom(source: any = {}) {
	        return new Config(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.theme = source["theme"];
	        this.font = source["font"];
	        this.font_size = source["font_size"];
	        this.line_wrap = source["line_wrap"];
	        this.line_numbers = source["line_numbers"];
	    }
	}
	export class FontResult {
	    font: string;
	    font_size: number;
	
	    static createFrom(source: any = {}) {
	        return new FontResult(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.font = source["font"];
	        this.font_size = source["font_size"];
	    }
	}

}

