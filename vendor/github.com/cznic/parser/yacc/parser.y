// CAUTION: Generated by yy - DO NOT EDIT.

%{
// Copyright 2015 The parser Authors. All rights reserved.  Use
// of this source code is governed by a BSD-style license that can be found in
// the LICENSE file.
//
// This is a derived work base on the original at
// 
// http://pubs.opengroup.org/onlinepubs/009695399/utilities/yacc.html
//
// The original work is
//
// Copyright © 2001-2004 The IEEE and The Open Group, All Rights reserved.
// 
// Grammar for the input to yacc.

package parser

import (
	"go/token"
)
%}

%union {
	node  Node
	Token *Token
}

%token	<Token>
	','
	';'
	'<'
	'>'
	'{'
	'|'
	'}'
	COMMENT
	C_IDENTIFIER    "rule name"
	ERROR_VERBOSE   "%error-verbose"
	IDENTIFIER      "identifier"
	LCURL           "%{"
	LEFT            "%left"
	MARK            "%%"
	NONASSOC        "%nonassoc"
	NUMBER          "number"
	PREC            "%prec"
	PRECEDENCE      "%precedence"
	RCURL           "%}"
	RIGHT           "%right"
	START           "%start"
	STRING_LITERAL  "string literal"
	TOKEN           "%token"
	TYPE            "%type"
	UNION           "%union"

%type	<node>
	Action
	Definition
	DefinitionList
	LiteralStringOpt
	Name
	NameList
	Precedence
	ReservedWord
	Rule
	RuleItemList
	RuleList
	Specification
	Tag
	Tail

%start Specification

%%

Action:
	'{'
	{
		lx := yylex.(*lexer)
		lx.values2 = append([]string(nil), lx.values...)
		lx.positions2 = append([]token.Pos(nil), lx.positions...)
	}
	'}'
	{
		lx := yylex.(*lexer)
		lhs := &Action{
			Token:   $1,
			Token2:  $3,
		}
		$$ = lhs
		for i, v := range lx.values2 {
			a := lx.parseActionValue(lx.positions2[i], v)
			if a != nil {
				lhs.Values = append(lhs.Values, a)
			}
		}
	}

Definition:
	START IDENTIFIER
	{
		$$ = &Definition{
			Token:   $1,
			Token2:  $2,
		}
	}
|	UNION
	{
		lx := yylex.(*lexer)
		lhs := &Definition{
			Case:   1,
			Token:  $1,
		}
		$$ = lhs
		lhs.Value = lx.value
	}
|	LCURL
	{
		lx := yylex.(*lexer)
		lx.pos2 = lx.pos
		lx.value2 = lx.value
	}
	RCURL
	{
		lx := yylex.(*lexer)
		lhs := &Definition{
			Case:    2,
			Token:   $1,
			Token2:  $3,
		}
		$$ = lhs
		lhs.Value = lx.value2
	}
|	ReservedWord Tag NameList
	{
		lhs := &Definition{
			Case:          3,
			ReservedWord:  $1.(*ReservedWord),
			Tag:           $2.(*Tag),
			NameList:      $3.(*NameList).reverse(),
		}
		$$ = lhs
		for n := lhs.NameList; n != nil; n = n.NameList {
			lhs.Nlist = append(lhs.Nlist, n.Name)
		}
	}
|	ReservedWord Tag
	{
		$$ = &Definition{
			Case:          4,
			ReservedWord:  $1.(*ReservedWord),
			Tag:           $2.(*Tag),
		}
	}
|	ERROR_VERBOSE
	{
		$$ = &Definition{
			Case:   5,
			Token:  $1,
		}
	}

DefinitionList:
	/* empty */
	{
		$$ = (*DefinitionList)(nil)
	}
|	DefinitionList Definition
	{
		lx := yylex.(*lexer)
		lhs := &DefinitionList{
			DefinitionList:  $1.(*DefinitionList),
			Definition:      $2.(*Definition),
		}
		$$ = lhs
		lx.defs = append(lx.defs, lhs.Definition)
	}

LiteralStringOpt:
	/* empty */
	{
		$$ = (*LiteralStringOpt)(nil)
	}
|	STRING_LITERAL
	{
		$$ = &LiteralStringOpt{
			Token:  $1,
		}
	}

Name:
	IDENTIFIER LiteralStringOpt
	{
		lx := yylex.(*lexer)
		lhs := &Name{
			Token:             $1,
			LiteralStringOpt:  $2.(*LiteralStringOpt),
		}
		$$ = lhs
		lhs.Identifier = lx.ident(lhs.Token)
		lhs.Number = -1
	}
|	IDENTIFIER NUMBER LiteralStringOpt
	{
		lx := yylex.(*lexer)
		lhs := &Name{
			Case:              1,
			Token:             $1,
			Token2:            $2,
			LiteralStringOpt:  $3.(*LiteralStringOpt),
		}
		$$ = lhs
		lhs.Identifier = lx.ident(lhs.Token)
		lhs.Number = lx.number(lhs.Token2)
	}

NameList:
	Name
	{
		$$ = &NameList{
			Name:  $1.(*Name),
		}
	}
|	NameList Name
	{
		$$ = &NameList{
			Case:      1,
			NameList:  $1.(*NameList),
			Name:      $2.(*Name),
		}
	}
|	NameList ',' Name
	{
		$$ = &NameList{
			Case:      2,
			NameList:  $1.(*NameList),
			Token:     $2,
			Name:      $3.(*Name),
		}
	}

Precedence:
	/* empty */
	{
		$$ = (*Precedence)(nil)
		}
|	PREC IDENTIFIER
	{
		lx := yylex.(*lexer)
		lhs := &Precedence{
			Case:    1,
			Token:   $1,
			Token2:  $2,
		}
		$$ = lhs
		lhs.Identifier = lx.ident(lhs.Token2)
	}
|	PREC IDENTIFIER Action
	{
		lx := yylex.(*lexer)
		lhs := &Precedence{
			Case:    2,
			Token:   $1,
			Token2:  $2,
			Action:  $3.(*Action),
		}
		$$ = lhs
		lhs.Identifier = lx.ident(lhs.Token2)
	}
|	Precedence ';'
	{
		$$ = &Precedence{
			Case:        3,
			Precedence:  $1.(*Precedence),
			Token:       $2,
		}
	}

ReservedWord:
	TOKEN
	{
		$$ = &ReservedWord{
			Token:  $1,
		}
	}
|	LEFT
	{
		$$ = &ReservedWord{
			Case:   1,
			Token:  $1,
		}
	}
|	RIGHT
	{
		$$ = &ReservedWord{
			Case:   2,
			Token:  $1,
		}
	}
|	NONASSOC
	{
		$$ = &ReservedWord{
			Case:   3,
			Token:  $1,
		}
	}
|	TYPE
	{
		$$ = &ReservedWord{
			Case:   4,
			Token:  $1,
		}
	}
|	PRECEDENCE
	{
		$$ = &ReservedWord{
			Case:   5,
			Token:  $1,
		}
	}

Rule:
	C_IDENTIFIER RuleItemList Precedence
	{
		lx := yylex.(*lexer)
		lhs := &Rule{
			Token:         $1,
			RuleItemList:  $2.(*RuleItemList).reverse(),
			Precedence:    $3.(*Precedence),
		}
		$$ = lhs
		lx.ruleName = lhs.Token
		lhs.Name = lhs.Token
	}
|	'|' RuleItemList Precedence
	{
		lx := yylex.(*lexer)
		lhs := &Rule{
			Case:          1,
			Token:         $1,
			RuleItemList:  $2.(*RuleItemList).reverse(),
			Precedence:    $3.(*Precedence),
		}
		$$ = lhs
		lhs.Name = lx.ruleName
	}

RuleItemList:
	/* empty */
	{
		$$ = (*RuleItemList)(nil)
	}
|	RuleItemList IDENTIFIER
	{
		$$ = &RuleItemList{
			Case:          1,
			RuleItemList:  $1.(*RuleItemList),
			Token:         $2,
		}
	}
|	RuleItemList Action
	{
		$$ = &RuleItemList{
			Case:          2,
			RuleItemList:  $1.(*RuleItemList),
			Action:        $2.(*Action),
		}
	}
|	RuleItemList STRING_LITERAL
	{
		$$ = &RuleItemList{
			Case:          3,
			RuleItemList:  $1.(*RuleItemList),
			Token:         $2,
		}
	}

RuleList:
	C_IDENTIFIER RuleItemList Precedence
	{
		lx := yylex.(*lexer)
		lhs := &RuleList{
			Token:         $1,
			RuleItemList:  $2.(*RuleItemList).reverse(),
			Precedence:    $3.(*Precedence),
		}
		$$ = lhs
		lx.ruleName = lhs.Token
		rule := &Rule{
			Token: lhs.Token,
			Name: lhs.Token,
			RuleItemList: lhs.RuleItemList,
			Precedence: lhs.Precedence,
		}
		rule.collect()
		lx.rules = append(lx.rules, rule)
	}
|	RuleList Rule
	{
		lx := yylex.(*lexer)
		lhs := &RuleList{
			Case:      1,
			RuleList:  $1.(*RuleList),
			Rule:      $2.(*Rule),
		}
		$$ = lhs
		rule := lhs.Rule
		rule.collect()
		lx.rules = append(lx.rules, rule)
	}

Specification:
	DefinitionList "%%" RuleList Tail
	{
		lx := yylex.(*lexer)
		lhs := &Specification{
			DefinitionList:  $1.(*DefinitionList).reverse(),
			Token:           $2,
			RuleList:        $3.(*RuleList).reverse(),
			Tail:            $4.(*Tail),
		}
		$$ = lhs
		lhs.Defs = lx.defs
		lhs.Rules = lx.rules
		lx.spec = lhs
	}

Tag:
	/* empty */
	{
		$$ = (*Tag)(nil)
	}
|	'<' IDENTIFIER '>'
	{
		$$ = &Tag{
			Token:   $1,
			Token2:  $2,
			Token3:  $3,
		}
	}

Tail:
	"%%"
	{
		lx := yylex.(*lexer)
		lhs := &Tail{
			Token:  $1,
		}
		$$ = lhs
		lhs.Value = lx.value
	}
|	/* empty */
	{
		$$ = (*Tail)(nil)
	}