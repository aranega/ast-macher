Class {
	#name : #SequenceMatcher,
	#superclass : #Matcher,
	#instVars : [
		'matchers',
		'condition'
	],
	#category : #'AST-Matcher'
}

{ #category : #'as yet unclassified' }
SequenceMatcher class >> matchers: aMatcherCollection [
	^ self new matchers: aMatcherCollection
]

{ #category : #accessing }
SequenceMatcher >> at: index [
	^ matchers at: index
]

{ #category : #accessing }
SequenceMatcher >> condition: aBlock [
	condition := aBlock
]

{ #category : #accessing }
SequenceMatcher >> isSequenceMatcher [
	^ true
]

{ #category : #accessing }
SequenceMatcher >> match: aValue withContext: context [
	| sequenceSize sizeOfStarMatcher matcherArray starMatcher index newMatchers res collection |
	aValue ifNil: [ ^ false ].
	(aValue isCollection or: [ aValue isSequence or: [ aValue isBlock ] ]) ifFalse: [ ^ false ].
	collection := aValue isCollection
		ifTrue: [ aValue ]
		ifFalse: [ aValue isSequence ifTrue: [aValue statements] ifFalse: [ aValue body statements ] ].
	sequenceSize := collection size.
	sizeOfStarMatcher := sequenceSize
		- (matchers reject: [ :matcher | matcher isStarMatcher ]) size.
	sizeOfStarMatcher < 0
		ifTrue: [ ^ false ].
	starMatcher := matchers select: [ :matcher | matcher isStarMatcher ].
	starMatcher
		ifEmpty: [ sequenceSize ~= matchers size
				ifTrue: [ ^ false ].
			res := (1 to: sequenceSize)
				allSatisfy:
					[ :i | (matchers at: i) match: (collection at: i) withContext: context ].
			res
				and: [ condition
						ifNotNil: [ ^ condition valueWithArgumentsDictionary: context ] ].
			^ res ].
	starMatcher := starMatcher first.
	matcherArray := Array new: sizeOfStarMatcher.
	1 to: sizeOfStarMatcher do: [ :i | matcherArray at: i put: starMatcher ].
	index := matchers indexOf: starMatcher.
	newMatchers := matchers
		copyReplaceFrom: index
		to: index
		with: matcherArray.
	sequenceSize ~= newMatchers size
		ifTrue: [ ^ false ].
	res := (1 to: sequenceSize)
		allSatisfy: [ :i | 
			(newMatchers at: i)
				match: (collection at: i)
				withContext: context ].
	res
		and: [ condition
				ifNotNil: [ ^ condition valueWithArgumentsDictionary: context ] ].
	^ res
]

{ #category : #accessing }
SequenceMatcher >> matchers: aMatcherCollection [
	matchers := aMatcherCollection 
]
