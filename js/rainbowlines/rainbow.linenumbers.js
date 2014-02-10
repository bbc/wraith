/*
 * Copyright 2013 Nikita Nikishin
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Only install the plugin if Rainbow is present and has been loaded
if (window.Rainbow) window.Rainbow.linenumbers = (function(Rainbow) {
    /*
     * Splits up the DOM element containing
     * highlighted source code into an array of lines
     *
     * @param {block} Rainbow source element
     * @returns {Array}
     */
    this.splitLines = function(block) {
        // Each line is represented as an array
        var lines = [[]];
        
        // Caches the child nodes of the block
        var childNodes = block.childNodes;
        
        // For every child node
        for (var i = 0; i < childNodes.length; i++) {
            var elem = childNodes[i];
            
            // Array of lines in each element or text node
            var chunks = [];
            var lastLine = lines[lines.length - 1];
            
            // If the element is a text node
            if (elem.nodeType === 3) {
                // Just split up its node value
                chunks = elem.nodeValue.split('\n');
            } else {
                // Otherwise, we need to split up the HTML
                var stringChunks = elem.innerHTML.split('\n');
                
                // Wraps each chunk in the parent element. For example:
                // <b>foo\nbar</b> -> [<b>foo</b>, <b>bar</b>]
                for (var j = 0; j < stringChunks.length; j++) {
                    var wrapper = elem.cloneNode();
                    wrapper.innerHTML = stringChunks[j];
                    
                    chunks.push(wrapper.outerHTML);
                }
            }
            
            // The first chunk is a continuation of the last line
            // &#8203; is a zero-width space, which allows
            // empty lines to be copied
            lastLine.push(chunks[0] || '&#8203;');
            
            // Each subsequent chunk is its own line
            for (var k = 0; k < chunks.length - 1; k++) {
                lines.push([chunks[k + 1] || '&#8203;']);
            }
        }
        
        // Returns the array of lines
        return lines;
    };
    
    // Callback is called when Rainbow has highlighted a block
    Rainbow.onHighlight(function(block) {
        // This addresses an issue when Rainbow.color() is called multiple times.
        // Since code element is replaced with table element below,
        // second pass of Rainbow.color() will result in block.parentNode being null.
        if (!block || !block.parentNode) {
            return;
        }

        // Create a table wrapper
        var table = document.createElement('table');
        table.className = 'rainbow';
        table.setAttribute('data-language', block.getAttribute('data-language'));
        
        // Split up the lines of the block
        var lines = this.splitLines(block);
        
        // For each line
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i],
                index = i + 1;
            
            // Create a row
            var row = table.insertRow(-1);
            row.className = 'line line-' + index;
            
            // Create a cell which displays the line number with CSS
            var lineNumber = row.insertCell(-1);
            lineNumber.className = 'line-number';
            lineNumber.setAttribute('data-line-number', index);
            
            // Add in the actual line of source code
            var code = row.insertCell(-1);
            code.className = 'line-code';
            code.innerHTML = line.join('');
        }
        
        // This addresses an issue where pre element is being used.
        // Rainbow allows using either pre element directly, or a nested code element.
        // In the case of pre element, don't use parentNode as it may not be okay to clear it's content (e.g., <body>).
        var parent = block.nodeName === 'PRE' ? block : block.parentNode;

        // Clear the parent element and use the table in place of the <code> block
        parent.innerHTML = '';
        parent.appendChild(table);
    });
})(window.Rainbow);